//
//  QDict.swift
//  QuakeEd
//
//  Created by C.W. Betts on 9/7/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

import Foundation

/// Helper class that converts dicts read in from a file to NSDictionaries
class QDict: NSObject /*, NSCopying, NSCoding*/ {
	var dictionary = [String: String]()
	
	
	///Parse all keyword/value pairs within `{ }` 's
	func parseBraceBlock(fp: UnsafeMutablePointer<FILE>) -> Bool {
		var c: Int32 = 0
		var pair = dict_t()
		var string = Array<Int8>(count: 1024, repeatedValue: 0)
		
		c = FindBrace(fp);
		if (c == -1) {
			return false;
		}
		while c != 125 {
			FindBrace(fp);
			if (c == -1) {
				return false;
			}
			//		c = FindNonwhitespc(fp);
			//		if (c == -1)
			//			return NULL;
			//		CopyUntilWhitespc(fp,string);
			
			// JDC: fixed to allow quoted keys
			c = FindNonwhitespc(fp);
			if (c == -1) {
				return false;
			}
			c = fgetc(fp);
			if ( c == 34) {
				CopyUntilQuote(fp, &string);
			} else {
				ungetc (c,fp);
				CopyUntilWhitespc(fp, &string);
			}
			
			pair.key = UnsafeMutablePointer<Int8>(malloc(Int(strlen(string)) + 1))
			strcpy(pair.key, string);
			
			c = FindQuote(fp);
			CopyUntilQuote(fp, &string);
			pair.value =  UnsafeMutablePointer<Int8>(malloc(Int(strlen(string)) + 1))
			strcpy(pair.value,string);
			
			let swiftPair: (key: String, value: String) = (String(CString: pair.key, encoding: NSASCIIStringEncoding)!, String(CString: pair.key, encoding: NSASCIIStringEncoding)!)
			
			free(pair.key);
			free(pair.value)
			
			dictionary[swiftPair.key] = swiftPair.value
			//[super addElement:&pair];
			c = FindBrace(fp);
		}

		return true
	}
	
	class func dictionaryFromFile(fp: UnsafeMutablePointer<FILE>) -> NSMutableDictionary? {
		let aParse = QDict()
		if !aParse.parseBraceBlock(fp) {
			return nil
		}
		let toRet = NSMutableDictionary(dictionary: aParse.dictionary)
		
		return toRet
	}
}
