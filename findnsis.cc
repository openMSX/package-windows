// $Id$
//
#include <windows.h>
#include <iostream>

using std::cout;
using std::cerr;
using std::endl;

int main (int argc, char * argv[])
{
	bool succes;
	HKEY hkey;
	LONG result;
	DWORD length;
	DWORD type;
	unsigned char * buffer;
	result = RegOpenKeyEx (HKEY_LOCAL_MACHINE, "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\NSIS",0,KEY_READ,&hkey);
	succes = (result == ERROR_SUCCESS);
	if (succes){
		result = RegQueryValueEx (hkey,"InstallLocation",NULL,&type,NULL,&length);
		succes &= (result == ERROR_SUCCESS);
		if (succes){
			buffer = new unsigned char [length+1];
			result = RegQueryValueEx (hkey,"InstallLocation",NULL,&type,buffer,&length);
			succes &= (result == ERROR_SUCCESS);
			cout << buffer << endl;
		}
	}
	if (!succes){
		cerr << "Unable to determen NSIS location" << endl;
		exit (1);
	}	
}
