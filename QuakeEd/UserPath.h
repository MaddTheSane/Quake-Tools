/* 
 * UserPath.h by Bruce Blumberg, NeXT Computer, Inc.
 *
 * You may freely copy,distribute and re-use the code in this example. NeXT
 * disclaims any warranty of any kind, expressed or implied, as to its fitness
 * for any particular purpose
 *
 * This file and its associated .m file define a data structure and set of
 * functions aimed at facilitating the use of user paths. Here is a simple
 * example:
 *
 * UserPath *arect;
 * arect = newUserPath(); // creates an empty user path
 * beginUserPath(arect,YES);  // initialize user path and cache
 *   UPmoveto(arect,0.0,0.0); // add moveto to userpath; update bounding box
 *   UPrlineto(arect,0.0,100.0); // add rlineto to path; update bounding box
 *   UPrlineto(arect,100.0,0.0); // add rlineto to path; update bounding box
 *   UPrlineto(arect,0.0,-100.0); // add rlineto to path; update bounding box
 *   closePath(arect); // close path
 * endUserPath(arect,dps_stroke); // close user path and specify operator
 * sendUserPath(arect);
 *
 * As you will note, the set of routines manage the allocation and growth of
 * the operator and operand arrays, as well as the calculation of the bounding
 * box. A user path created via these functions may be optionally cached down
 * at the window server, or repeatedly sent down.  The user paths created by
 * this set of functions are all allocated in a unique zone.
 *
 * Note: the associated file is a .m file because it pulls in some .h files
 * which reference objective C methods. 
 */

#import <objc/objc.h>
#import <AppKit/AppKit.h>
//#import <dpsclient/dpsclient.h>

typedef NS_ENUM(int, DPSUserPathAction) {
    dps_uappend = 176,
    dps_ufill = 179,
    dps_ueofill = 178,
    dps_ustroke = 183,
    dps_ustrokepath = 364,
    dps_inufill = 93,
    dps_inueofill = 92,
    dps_inustroke = 312,
    dps_infill = 90,
    dps_ineofill = 89,
    dps_instroke = 311,
    dps_def = 51,
    dps_put = 120,
    dps_send = 113	/* This is really the null operator */
};

typedef struct _UP {
    NSBezierPath *bPath;
    DPSUserPathAction opForUserPath;
} UserPath;

/* UserPath functions */
NSZone *userPathZone();
///Creates a new User Path
UserPath *newUserPath();
///Frees User Path and its associated buffers
void freeUserPath(UserPath *up);
void debugUserPath(UserPath *up, BOOL shouldPing);
void growUserPath(UserPath *up);
void beginUserPath(UserPath *up, BOOL cache);
void endUserPath(UserPath *up, DPSUserPathAction op);
int sendUserPath(UserPath *up);
void UPmoveto(UserPath *up, float x, float y);
void UPrmoveto(UserPath *up, float x, float y);
void UPlineto(UserPath *up, float x, float y);
void UPrlineto(UserPath *up, float x, float y);
void UPcurveto(UserPath *up, float x1, float y1, float x2, float y2, float x3,
	       float y3);
void UPrcurveto(UserPath *up, float dx1, float dy1, float dx2, float dy2,
		float dx3, float dy3);
void UParc(UserPath *up, float x, float y, float r, float ang1, float ang2);
void UParcn(UserPath *up, float x, float y, float r, float ang1, float ang2);
void UParct(UserPath *up, float x1, float y1, float x2, float y2, float r);
void closePath(UserPath *up);
void addPts(UserPath *up, float x, float y);
void addOp(UserPath *up, int op);
void add(UserPath *up, int op, float x, float y);
void checkBBox(UserPath *up, float x, float y);
