//
//  oldPSFuncs.h
//  Chess
//
//  Created by C.W. Betts on 4/5/16.
//
//

#ifndef oldPSFuncs_h
#define oldPSFuncs_h

#include <Availability.h>
#include <AvailabilityMacros.h>

#if __LP64__
#define NO64_BIT UNAVAILABLE_ATTRIBUTE __OSX_AVAILABLE_BUT_DEPRECATED_MSG(__MAC_10_0, __MAC_10_0, __IPHONE_NA, __IPHONE_NA, "Use CoreGraphics or Cocoa Drawing methods instead.")
#else
#define NO64_BIT __OSX_AVAILABLE_BUT_DEPRECATED_MSG(__MAC_10_0, __MAC_10_0, __IPHONE_NA, __IPHONE_NA, "Use CoreGraphics or Cocoa Drawing methods instead.")
#endif

//
// PS routines without prototypes
//
void PScountframebuffers(int *count) NO64_BIT;
void PSmoveto(float x, float y) NO64_BIT;
void PSrmoveto(float x, float y) NO64_BIT;
void PSarc(float x, float y, float r, float angle1, float angle2) NO64_BIT;
void PSarcn(float x, float y, float r, float angle1, float angle2) NO64_BIT;
void PSarct(float x1, float y1, float x2, float y2, float r) NO64_BIT;
void PSflushgraphics(void) NO64_BIT;
void PSrectclip(float x, float y, float w, float h) NO64_BIT;
void PSrectfill(float x, float y, float w, float h) NO64_BIT;
void PSrectstroke(float x, float y, float w, float h) NO64_BIT;
void PSfill(void) NO64_BIT;
void PSeofill(void) NO64_BIT;
void PSstroke(void) NO64_BIT;
void PSstrokepath(void) NO64_BIT;
void PSinitclip(void) NO64_BIT;
void PSclip(void) NO64_BIT;
void PSeoclip(void) NO64_BIT;
void PSclippath(void) NO64_BIT;
void PSlineto(float x, float y) NO64_BIT;
void PSrlineto(float x, float y) NO64_BIT;
void PScurveto(float x1, float y1, float x2, float y2, float x3, float y3) NO64_BIT;
void PSrcurveto(float x1, float y1, float x2, float y2, float x3, float y3) NO64_BIT;
void PScurrentpoint(float *x, float *y) NO64_BIT;
void PSsetlinecap(int linecap) NO64_BIT;
void PSsetlinejoin(int linejoin) NO64_BIT;
void PSsetlinewidth(float width) NO64_BIT;
void PSsetgray(float gray) NO64_BIT;
void PSsetrgbcolor(float r, float g, float b) NO64_BIT;
void PSsetcmykcolor(float c, float m, float y, float k) NO64_BIT;
void PSsetalpha(float a) NO64_BIT;
void PStranslate(float x, float y) NO64_BIT;
void PSrotate(float angle) NO64_BIT;
void PSscale(float x, float y) NO64_BIT;
void PSconcat(const float m[]) NO64_BIT;
void PSsethalftonephase(int x, int y) NO64_BIT;
void PSnewpath(void) NO64_BIT;
void PSclosepath(void) NO64_BIT;
void PScomposite(float x, float y, float w, float h, int gstateNum, float dx, float dy, int op) NO64_BIT;
void PScompositerect(float x, float y, float w, float h, int op) NO64_BIT;
void PSshow(const char *s) NO64_BIT;
void PSashow(float w, float h, const char *s) NO64_BIT;
extern void PSgsave(void) NO64_BIT;
extern void PSgrestore(void) NO64_BIT;
void PSselectfont(const char*, float) NO64_BIT;
//extern void PSWait(void) NO64_BIT;

/// PSWait has no analogue in CoreGraphics and is a no-op in OS X 32-bit.
#define PSWait() /*Do nothing*/

#endif /* oldPSFuncs_h */
