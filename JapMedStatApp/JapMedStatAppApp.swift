//
//  JapMedStatAppApp.swift
//  JapMedStatApp
//
//  Created by Namikare Gikoha on 2021/02/13.
//

import SQLite
import SwiftUI

struct DrugDB
{
    var name: String
    var value: String
    init(name: String, value: String)
    {
        self.name = name
        self.value = value
    }
}

var dbarray = [DrugDB]()

func findName(name: String) -> String
{
    for it in dbarray
    {
        if it.name == name
        {
            return it.value
        }
    }
    return ""
}

// https://qiita.com/KikurageChan/items/807e84e3fa68bb9c4de6 からのコピペです

extension String
{
    // 絵文字など(2文字分)も含めた文字数を返します
    var length: Int
    {
        let string_NS = self as NSString
        return string_NS.length
    }

    // 正規表現の検索をします
    func pregMatche(pattern: String, options: NSRegularExpression.Options = []) -> Bool
    {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options)
        else
        {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, length))
        return matches.count > 0
    }

    // 正規表現の検索結果を利用できます
    func pregMatche(pattern: String, options: NSRegularExpression.Options = [], matches: inout [String]) -> Bool
    {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options)
        else
        {
            return false
        }
        let targetStringRange = NSRange(location: 0, length: length)
        let results = regex.matches(in: self, options: [], range: targetStringRange)
        for i in 0 ..< results.count
        {
            for j in 0 ..< results[i].numberOfRanges
            {
                let range = results[i].range(at: j)
                matches.append((self as NSString).substring(with: range))
            }
        }
        return results.count > 0
    }

    // 正規表現の置換をします
    func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String
    {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, length), withTemplate: with)
    }
}


// http://blog.livedoor.jp/eienf/archives/1067416079.html

extension String {
    var hankanaRange : NSRange {
        get {
            return String.rangeOfHankana(str: self)
        }
    }
    var stringWithoutHankana : String {
        get {
            var str = self
            var range = NSMakeRange(NSNotFound, 0)
            repeat {
                range = String.rangeOfHankana(str: str)
                str = String.convHan2Zen(string: str, range: range)
            } while ( range.location != NSNotFound )
            return str
        }
    }
    static func rangeOfHankana(str:String) -> NSRange {
        var location = NSNotFound
        var length = 0
        var i = 0
        let range = NSMakeRange(0xff61,0xff9f - 0xff61 + 1) // bug fix
        let characterSet = NSCharacterSet(range: range)
        for c in str.utf16 {
            if location == NSNotFound {
                if characterSet.characterIsMember(c) {
                    location = i
                    length = 1
                } else {
                    
                }
            } else {
                if characterSet.characterIsMember(c) {
                    length += 1
                } else {
                    break
                }
            }
            i += 1
        }
        return NSMakeRange(location, length)
    }
    static func convHan2Zen(string:String, range:NSRange) -> String {
        let str = NSMutableString(string: string)
        var cfr = CFRangeMake(range.location == NSNotFound ? kCFNotFound : range.location, range.length)
        CFStringTransform(str, &cfr, kCFStringTransformFullwidthHalfwidth, true)
        return str as String
    }
}

func japmedstat(text: String) -> String
{
    var drugblock: Bool = false
    var dbstr = ""
    var assessblock: Bool = false
    var abstr = ""
    var outstr = ""

    text.enumerateLines
    { line, _ in
        var ans: [String] = []
        let linex = line.trimmingCharacters(in: .whitespaces)

        if linex == "" || linex.hasPrefix("A)")
        {
            // skip
        }
        else if linex.hasPrefix("# ")
        {
            if drugblock
            {
                // drug block end, starts assessment block
                outstr += dbstr
                abstr = linex + "\n"
                assessblock = true
                drugblock = false
            }
            else
            {
                abstr = abstr + linex + "\n"
            }
        }
        else if line.pregMatche(pattern: "^([0-9]+)y([0-9]+)m(.*)$",
                                options: NSRegularExpression.Options.anchorsMatchLines,
                                matches: &ans)
        {
            if assessblock
            {
                // assessment block end, starts drug block
                outstr += abstr
                dbstr = ""
                drugblock = true
                assessblock = false
            }
            // age
            outstr += "\n" + ans[1] + "歳 " + ans[2] + "ヶ月  " + ans[3] + "\n"
            drugblock = true
        }
        else if drugblock
        {
            var liney = linex
            if liney.contains("錠") ||
                liney.contains("坐剤") ||
                liney.contains("ガーグル") ||
                liney.contains("シロップ") ||
                liney.contains("cap") ||
                liney.contains("mL") ||
                liney.contains("個") ||
                liney.contains("枚") ||
                liney.contains("散") ||
                liney.contains("粒") ||
                liney.contains("テープ") ||
                liney.contains("ＤＳ") ||
                liney.contains("注")
            {
                liney = liney.pregReplace(pattern: "（.*）", with: "")
                //let liney1 = liney.applyingTransform(.fullwidthToHalfwidth, reverse: true)!
                let liney1 = liney.stringWithoutHankana
                if liney1.pregMatche(pattern: "([ァ-ンＡ-Ｚａ-ｚー塩化酸・]+)(.*)", matches: &ans)
                {
                    var matchstr: String = ""

                    matchstr = findName(name: ans[1])
                    if matchstr != ""
                    {
                        dbstr = dbstr + liney + "  " + matchstr + "\n"
                    }
                    else
                    {
                        dbstr = dbstr + liney + "  ?\(ans[1])?\n"
                    }
                }
                else
                {
                    dbstr = dbstr + liney + "\n"
                }
            }
            else if assessblock
            {
                if linex.hasPrefix("# ")
                {
                    abstr = abstr + linex + "\n"
                }
            }
        }
    }
    // flush blocks
    if drugblock
    {
        outstr += dbstr
    }
    if assessblock
    {
        outstr += abstr
    }
    return outstr
}

@main
struct JapMedStatAppApp: App
{
    init()
    {
        let filepath = Bundle.main.path(forResource: "medicine", ofType: "sqlite")

        let db = try! Connection(filepath!)

        let drugs = Table("JAPMEDSTAT")
        let name = Expression<String>("NAME") // case sensitive
        let value = Expression<String>("VALUE")

        for drug in try! db.prepare(drugs)
        {
            let it = DrugDB(name: drug[name], value: drug[value])
            dbarray.append(it)
        }
    }

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
        }
    }
}
