// cmdlib.c

#include "cmdlib.h"

#include <CoreFoundation/CoreFoundation.h>

#define PATHSEPERATOR   '/'


/*
================
I_FloatTime
================
*/
double I_FloatTime (void)
{
	struct timeval tp;
	struct timezone tzp;
	static time_t	secbase;

	gettimeofday(&tp, &tzp);
	
	if (!secbase)
	{
		secbase = tp.tv_sec;
		return tp.tv_usec/1000000.0;
	}
	
	return (tp.tv_sec - secbase) + tp.tv_usec/1000000.0;
}


char		com_token[1024];
bool		com_eof;

/*
==============
COM_Parse

Parse a token out of a string
==============
*/
char *COM_Parse (char *data)
{
	int		c;
	int		len;
	
	com_eof = false;
	
	len = 0;
	com_token[0] = 0;
	
	if (!data)
		return NULL;
		
// skip whitespace
skipwhite:
	while ( (c = *data) <= ' ')
	{
		if (c == 0)
		{
			com_eof = true;
			return NULL;			// end of file;
		}
		data++;
	}
	
// skip // comments
	if (c=='/' && data[1] == '/')
	{
		while (*data && *data != '\n')
			data++;
		goto skipwhite;
	}
	

// handle quoted strings specially
	if (c == '\"')
	{
		data++;
		do
		{
			c = *data++;
			if (c=='\"')
			{
				com_token[len] = 0;
				return data;
			}
			com_token[len] = c;
			len++;
		} while (1);
	}

// parse single characters
	if (c=='{' || c=='}'|| c==')'|| c=='(' || c=='\'' || c==':')
	{
		com_token[len] = c;
		len++;
		com_token[len] = 0;
		return data+1;
	}

// parse a regular word
	do
	{
		com_token[len] = c;
		data++;
		len++;
		c = *data;
	if (c=='{' || c=='}'|| c==')'|| c=='(' || c=='\'' || c==':')
			break;
	} while (c>32);
	
	com_token[len] = 0;
	return data;
}

/*
================
=
= filelength
=
================
*/

off_t filelength (int handle)
{
	struct stat	fileinfo;
    
	if (fstat (handle,&fileinfo) == -1)
	{
		fprintf (stderr,"Error fstating");
		exit (1);
	}

	return fileinfo.st_size;
}

off_t tell (int handle)
{
	return lseek (handle, 0, L_INCR);
}

char *strupr (char *start)
{
	char	*in;
	in = start;
	while (*in)
	{
		*in = toupper(*in);
		in++;
	}
	return start;
}

char *strlower (char *start)
{
	char	*in;
	in = start;
	while (*in)
	{
		*in = tolower(*in);
		in++;
	}
	return start;
}


/* globals for command line args */
extern int NXArgc;
extern char **NXArgv;
#define myargc	NXArgc
#define myargv	NXArgv


/*
=============================================================================

						MISC FUNCTIONS

=============================================================================
*/


/*
=================
=
= CheckParm
=
= Checks for the given parameter in the program's command line arguments
=
= Returns the argument number (1 to argc-1) or 0 if not present
=
=================
*/

int CheckParm (char *check)
{
	int             i;

	for (i = 1;i<myargc;i++)
	{
		if ( !stricmp(check, myargv[i]) )
			return i;
	}

	return 0;
}




int SafeOpenWrite (const char *filename)
{
	int     handle;

	umask (0);
	
	handle = open(filename,O_RDWR | O_CREAT | O_TRUNC
	, 0666);

	if (handle == -1)
		Error ("Error opening %s: %s",filename,strerror(errno));

	return handle;
}

int SafeOpenRead (const char *filename)
{
	int     handle;

	handle = open(filename,O_RDONLY);

	if (handle == -1)
		Error ("Error opening %s: %s",filename,strerror(errno));

	return handle;
}


void SafeRead (int handle, void *buffer, long count)
{
	ssize_t        iocount;

	iocount = read (handle,buffer,count);
	if (iocount != count)
		Error ("File read failure");
}


void SafeWrite (int handle, void *buffer, long count)
{
	ssize_t        iocount;

	iocount = write (handle,buffer,count);
	if (iocount != count)
		Error ("File write failure");
}


void *SafeMalloc (long size)
{
	void *ptr;

	ptr = malloc (size);

	if (!ptr)
		Error ("Malloc failure for %lu bytes",size);

	return ptr;
}


/*
==============
=
= LoadFile
=
= appends a 0 byte
==============
*/

long    LoadFile (const char *filename, void **bufferptr)
{
	int             handle;
	long    length;
	void    *buffer;

	handle = SafeOpenRead (filename);
	length = filelength (handle);
	buffer = SafeMalloc (length+1);
	((char *)buffer)[length] = 0;
	SafeRead (handle, buffer, length);
	close (handle);

	*bufferptr = buffer;
	return length;
}


/*
==============
=
= SaveFile
=
==============
*/

void    SaveFile (const char *filename, void *buffer, long count)
{
	int             handle;

	handle = SafeOpenWrite (filename);
	SafeWrite (handle, buffer, count);
	close (handle);
}



void DefaultExtension (char *path, char *extension)
{
	char    *src;
//
// if path doesn't have a .EXT, append extension
// (extension should include the .)
//
	src = path + strlen(path) - 1;

	while (*src != PATHSEPERATOR && src != path)
	{
		if (*src == '.')
			return;                 // it has an extension
		src--;
	}

	strcat (path, extension);
}


void DefaultPath (char *path, char *basepath)
{
	char    temp[128];

	if (path[0] == PATHSEPERATOR)
		return;                   // absolute path location
	strcpy (temp,path);
	strcpy (path,basepath);
	strcat (path,temp);
}


void    StripFilename (char *path)
{
	size_t             length;

	length = strlen(path)-1;
	while (length > 0 && path[length] != PATHSEPERATOR)
		length--;
	path[length] = 0;
}

void    StripExtension (char *path)
{
	size_t             length;

	length = strlen(path)-1;
	while (length > 0 && path[length] != '.')
		length--;
	if (length)
		path[length] = 0;
}


/*
====================
=
= Extract file parts
=
====================
*/

void ExtractFilePath (char *path, char *dest)
{
	char    *src;

	src = path + strlen(path) - 1;

//
// back up until a \ or the start
//
	while (src != path && *(src-1) != PATHSEPERATOR)
		src--;

	memcpy (dest, path, src-path);
	dest[src-path] = 0;
}

void ExtractFileBase (char *path, char *dest)
{
	char    *src;

	src = path + strlen(path) - 1;

//
// back up until a \ or the start
//
	while (src != path && *(src-1) != PATHSEPERATOR)
		src--;

	while (*src && *src != '.')
	{
		*dest++ = *src++;
	}
	*dest = 0;
}

void ExtractFileExtension (char *path, char *dest)
{
	char    *src;

	src = path + strlen(path) - 1;

//
// back up until a . or the start
//
	while (src != path && *(src-1) != '.')
		src--;
	if (src == path)
	{
		*dest = 0;	// no extension
		return;
	}

	strcpy (dest,src);
}


/*
==============
=
= ParseNum / ParseHex
=
==============
*/

long ParseHex (char *hex)
{
	char    *str;
	long    num;

	num = 0;
	str = hex;

	while (*str)
	{
		num <<= 4;
		if (*str >= '0' && *str <= '9')
			num += *str-'0';
		else if (*str >= 'a' && *str <= 'f')
			num += 10 + *str-'a';
		else if (*str >= 'A' && *str <= 'F')
			num += 10 + *str-'A';
		else
			Error ("Bad hex number: %s",hex);
		str++;
	}

	return num;
}


long ParseNum (char *str)
{
	if (str[0] == '$')
		return ParseHex (str+1);
	if (str[0] == '0' && str[1] == 'x')
		return ParseHex (str+2);
	return atol (str);
}


int GetKey (void)
{
	return getchar ();
}


/*
============================================================================

					BYTE ORDER FUNCTIONS

============================================================================
*/


short   BigShort (short l)
{
	return CFSwapInt16BigToHost(l);
}

short   LittleShort (short l)
{
	return CFSwapInt16LittleToHost(l);
}


int    BigLong (int l)
{
	return CFSwapInt32BigToHost(l);
}

int    LittleLong (int l)
{
	return CFSwapInt32LittleToHost(l);
}

float	BigFloat (float l)
{
	union {int b; float f;} in, out;
	
	in.f = l;
	out.b = CFSwapInt32BigToHost(in.b);

	return out.f;
}

float	LittleFloat (float l)
{
	union {int b; float f;} in, out;
	
	in.f = l;
	out.b = CFSwapInt32LittleToHost(in.b);
	
	return out.f;
}

