
#include "qedefs.h"


char	token[MAXTOKEN];
bool	unget;
char	*script_p;
int		scriptline;

void	StartTokenParsing (char *data)
{
	scriptline = 1;
	script_p = data;
	unget = false;
}

bool GetToken (bool crossline)
{
	char    *token_p;

	if (unget)                         // is a token allready waiting?
		return true;

//
// skip space
//
skipspace:
	while (*script_p <= 32)
	{
		if (!*script_p)
		{
			if (!crossline)
				Error ("Line %i is incomplete",scriptline);
			return false;
		}
		if (*script_p++ == '\n')
		{
			if (!crossline)
				Error ("Line %i is incomplete",scriptline);
			scriptline++;
		}
	}

	if (script_p[0] == '/' && script_p[1] == '/')	// comment field
	{
		if (!crossline)
			Error ("Line %i is incomplete\n",scriptline);
		while (*script_p++ != '\n')
			if (!*script_p)
			{
				if (!crossline)
					Error ("Line %i is incomplete",scriptline);
				return false;
			}
		goto skipspace;
	}

//
// copy token
//
	token_p = token;

	if (*script_p == '"')
	{
		script_p++;
		while ( *script_p != '"' )
		{
			if (!*script_p)
				Error ("EOF inside quoted token");
			*token_p++ = *script_p++;
			if (token_p == &token[MAXTOKEN])
				Error ("Token too large on line %i",scriptline);
		}
		script_p++;
	}
	else while ( *script_p > 32 )
	{
		*token_p++ = *script_p++;
		if (token_p == &token[MAXTOKEN])
			Error ("Token too large on line %i",scriptline);
	}

	*token_p = 0;
	
	return true;
}

void UngetToken ()
{
	unget = true;
}





void qprintf (const char *fmt, ...)		// prints text to cmd_out_i
{
	va_list			argptr;
	static char		string[1024];

	va_start (argptr, fmt);
	vsprintf (string, fmt,argptr);
	va_end (argptr);

	[g_cmd_out_i setStringValue: @(string)];
	//NXPing ();
	
	return;
}


/*
=================
Error

For abnormal program terminations
=================
*/
BOOL	in_error;
void Error (const char *error, ...)
{
	va_list		argptr;
	
	va_start (argptr,error);
	ErrorV(error, argptr);
	va_end (argptr);
}

void ErrorV (const char* error, va_list argptr)
{
	static char		string[1024];
	if (in_error)
		[NSApp terminate: NULL];
	in_error = YES;
	vsnprintf (string,sizeof(string),error,argptr);
	strncat (string, "\nmap saved to "FN_CRASHSAVE,sizeof(string) - strlen(string) - 1);
	
	[map_i writeMapFile: FN_CRASHSAVE useRegion: NO];
	NSRunAlertPanel (@"Error",@"%@",NULL,NULL,NULL, @(string));
	
	[NSApp terminate: NULL];
}


void CleanupName (char *in, char *out)
{
	int		i;
	
	for (i=0 ; i< 16 ; i++ )
	{
		if (!in[i])
			break;
			
		out[i] = toupper(in[i]);
	}
	
	for ( ; i< 16 ; i++ )
		out[i] = 0;
}


void PrintRect (NSRect *r)
{
	printf ("(%4.0f, %4.0f) + (%4.0f, %4.0f) = (%4.0f,%4.0f)\n"
		,r->origin.x,r->origin.y,
		r->size.width, r->size.height, r->origin.x+r->size.width,
		r->origin.y+r->size.height);
}


/*
============
FileTime

returns -1 if not present
============
*/
time_t	FileTime (char *path)
{
	struct	stat	buf;
	
	if (stat (path,&buf) == -1)
		return -1;
	
	return buf.st_mtime;
}

/*
============
CreatePath
============
*/
void	CreatePath (char *path)
{
	char	*ofs;
	
	for (ofs = path+1 ; *ofs ; ofs++)
	{
		if (*ofs == '/')
		{	// create the directory
			*ofs = 0;
			mkdir (path,0777);
			*ofs = '/';
		}
	}
}

off_t I_FileOpenRead (char *path, int *handle)
{
	int	h;
	struct stat	fileinfo;
    
	
	h = open (path, O_RDONLY, 0666);
	*handle = h;
	if (h == -1)
		return -1;
	
	if (fstat (h,&fileinfo) == -1)
		Error ("Error fstating %s", path);

	return fileinfo.st_size;
}

int I_FileOpenWrite (char *path)
{
	int     handle;

	umask (0);
	
	handle = open(path,O_RDWR | O_CREAT | O_TRUNC
	, 0666);

	if (handle == -1)
		Error ("Error opening %s: %s", path,strerror(errno));

	return handle;
}

/*
============
Sys_UpdateFile

Copies a more recent net file to the local drive
============
*/
void Sys_UpdateFile (char *path, char *netpath)
{
	time_t	ltime, ntime;
	int		in, out;
	off_t	size;
	char	*buf;
	
	ltime = FileTime (path);
	ntime = FileTime (netpath);
	
	if (ntime <= ltime)
		return;		// up to date
		
// copy the file
	printf ("UpdateFile: copying %s to %s...\n", netpath, path);
	
	size = I_FileOpenRead (netpath, &in);
	buf = malloc (size);
	if (read (in, buf, size) != size)
		Error ("UpdateFile: couldn't read all of %s", netpath);
	close (in);

	CreatePath (path);	
	out = I_FileOpenWrite (path);
	write (out, buf, size);
	close (out);
	
}


