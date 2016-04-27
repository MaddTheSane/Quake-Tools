
#import <AppKit/AppKit.h>

typedef struct
{
	char	*key;
	char	*value;
} dict_t;

@interface Dict: NSObject <NSCopying> //Storage (?)
{
	NSMutableDictionary<NSString*,NSString*> *intDict;
}

- (instancetype)initFromFile:(FILE *)fp;

- (NSArray<NSString*>*) parseMultipleFrom:(NSString *)value;
- (int) getValueUnits:(NSString *)key;
- (BOOL)delString:(NSString *)string fromValue:(NSString *)key;
- (BOOL)addString:(NSString *)string toValue:(NSString *)key;
- (NSString *)convertListToString:(id)list DEPRECATED_ATTRIBUTE;
+ (NSString*)convertArrayToString:(NSArray<NSString*>*)list;
- (NSString *)getStringFor:(NSString *)name;
- (void)removeKeyword:(NSString *)key;
- (unsigned int)getValueFor:(NSString *)name;
- (void)changeStringFor:(NSString *)key to:(NSString *)value;
- (dict_t *) findKeyword:(NSString *)key UNAVAILABLE_ATTRIBUTE;
- (BOOL)containsObjectForKey:(NSString*)key;

- (void)writeBlockTo:(FILE *)fp;
- (BOOL)writeFile:(NSString *)path;

// INTERNAL
- (instancetype)init;
- (BOOL) parseBraceBlock:(FILE *)fp;
- (void)setupMultiple:(NSString *)value;
- (NSString *)getNextParameter;

- (NSDictionary*)toNSDictionary;

//From the old Storage class?
@property (readonly) NSInteger count;
- (void)addElement:(dict_t*)elem;

@end

int	GetNextChar(FILE *fp);
void CopyUntilWhitespc(FILE *fp,char *buffer);
void CopyUntilQuote(FILE *fp,char *buffer);
int FindBrace(FILE *fp);
int FindQuote(FILE *fp);
int FindWhitespc(FILE *fp);
int FindNonwhitespc(FILE *fp);

char *FindWhitespcInBuffer(char *buffer);
char *FindNonwhitespcInBuffer(char *buffer);
