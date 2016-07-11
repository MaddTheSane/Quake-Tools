//
//  QDict.swift
//  QuakeEd
//
//  Created by C.W. Betts on 9/7/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

import Foundation

private func FindBrace(fp: UnsafeMutablePointer<FILE>) -> Int32 {
	let count = 800;
	var c: Int32 = 0
	
	for _ in 0 ..< count {
		c = GetNextChar(fp);
		if c == EOF {
			return -1;
		}
		if c == 123 || c == 125 {
			return c;
		}
	}
	return -1;
}

private func FindNonwhitespc(fp: UnsafeMutablePointer<FILE>) -> Int32 {
	let count = 800;
	var c: Int32 = 0
	
	for _ in 0 ..< count {
		c = GetNextChar(fp);
		if c == EOF {
			return -1;
		}
		if c > 20 {
			ungetc(c,fp);
			return c;
		}
	}
	return -1;
}

private func FindQuote(fp: UnsafeMutablePointer<FILE>) -> Int32 {
	let count = 800;
	var c: Int32 = 0
	
	for _ in 0 ..< count {
		c = GetNextChar(fp);
		if c == EOF {
			return -1;
		}
		if c == 34 {
			return c;
		}
	}
	return -1;
}

private func GetNextChar(fp: UnsafeMutablePointer<FILE>) -> Int32 {
	var c = getc(fp);
	if (c == EOF) {
		return -1;
	}
	if c == 0x2F {		// parse comments
		var c2 = getc(fp);
		if c2 == 0x2F {
			
			while(c2 != 10) {
				c2 = getc(fp)
			}
			c = getc(fp);
		} else {
			ungetc(c2,fp);
		}
	}
	return c;
}


private func CopyUntilQuote(fp: UnsafeMutablePointer<FILE>, _ buffer1: UnsafeMutablePointer<Int8>) {
	let count = 800;
	var buffer = buffer1
	var c: Int32 = 0
	
	for _ in 0 ..< count {
		c = GetNextChar(fp);
		if c == EOF {
			return;
		}
		if c == 34 {
			buffer.memory = 0;
			return;
		}
		buffer = buffer.advancedBy(1)
		buffer.memory = Int8(c)
	}
}

private func CopyUntilWhitespc(fp: UnsafeMutablePointer<FILE>, _ buffer1: UnsafeMutablePointer<Int8>) {
	let	count = 800;
	var buffer = buffer1
	var	c: Int32 = 0
	
	for _ in 0 ..< count {
		c = GetNextChar(fp);
		if c == EOF {
			return;
		}
		if c <= 20 {
			buffer.memory = 0;
			return;
		}
		buffer = buffer.advancedBy(1)
		buffer.memory = Int8(c)
	}
}


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
	
	class func dictionaryFromFile(fp: UnsafeMutablePointer<FILE>) -> [String: String]? {
		let aParse = QDict()
		if !aParse.parseBraceBlock(fp) {
			return nil
		}
		let toRet = aParse.dictionary
		
		return toRet
	}
}
