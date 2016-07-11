

#import <Foundation/Foundation.h>

#define	MAX_KEY		64
#define	MAX_VALUE	128
typedef struct epair_s
{
	struct epair_s	*next;
	char	key[MAX_KEY];
	char	value[MAX_VALUE];
} epair_t;

// an Entity is a list of brush objects, with additional key / value info

@interface Entity : NSObject <NSCopying>
{
	NSDictionary<NSString*,NSString*>	*epairs;
	BOOL	modifiable;
}

- (instancetype)initWithClass: (char *)classname;
- (instancetype)initFromTokens;

@property (nonatomic) BOOL modifiable;

- (char *)targetname;

- (void)writeToFILE: (FILE *)f region:(BOOL)reg;

- (char *)valueForQKey: (char *)k;
- (void)getVector: (vec3_t)v forKey: (char *)k;
- (void)setKey:(char *)k toValue:(char *)v;
@property (readonly) int numPairs;
- (epair_t *)epairs;
- (void)removeKeyPair: (char *)key;

@end


