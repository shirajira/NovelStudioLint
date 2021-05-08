//--------------------------------------------------------------------------//
// NovelStudioLint - NovelStudioLint.swift
//
// Copyright 2021 shirajira <contact@novel-stud.io>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//--------------------------------------------------------------------------//

import Foundation

public class NovelStudioLint {

    private static let fullWidthWhiteSpace = "　"  // Full-width white-space
    private static let lineFeed: String = "\n"  // Line-feed

    // MARK: - APIs

    /**
     Delete spaces located the end of the sentence.
     - parameter sentence: Sentence
     - returns: Sentence
     */
    public static func deleteEndSpaces(sentence: String) -> String {
        let preprocessed = _preprocess(sentence: sentence)
        let paragraphs = _separate(sentence: preprocessed)
        var ret: [String] = []
        for paragraph in paragraphs {
            var formatted: String = ""

            var sourceBuffer = paragraph
            while true {
                formatted = _deleteEndSpace(paragraph: sourceBuffer)
                if formatted == sourceBuffer {
                    break
                }
                sourceBuffer = formatted
            }
            ret.append(formatted)
        }
        return _combine(paragraphs: ret)
    }

    /**
     Insert an indent into each paragraph.
     - parameter sentence: Sentence
     - returns: Indented sentence
     */
    public static func insertIndent(sentence: String) -> String {
        let preprocessed = _preprocess(sentence: sentence)
        let paragraphs = _separate(sentence: preprocessed)
        var ret: [String] = []
        for paragraph in paragraphs {
            var formatted: String = ""

            if _checkIndented(paragraph: paragraph) {
                formatted = paragraph
            } else if _checkDialogParagraph(paragraph: paragraph) {
                formatted = paragraph
            } else {
                formatted = _indent(paragraph: paragraph)
            }
            ret.append(formatted)
        }
        return _combine(paragraphs: ret)
    }

    // MARK: - Utilities

    /**
     Preprocess: Replace half-width marks to full-width.
     - parameter sentence: Sentence may contain half-width marks (white-spaces, brackets and parentheses)
     - returns: Sentence may not contains half-width marks
     */
    internal static func _preprocess(sentence: String) -> String {
        let replacementRule = [
            " ": "　",  // White-space
            "｢": "「",  // Opening bracket
            "｣": "」",  // Closing bracket
            "(": "（",  // Opening parenthesis
            ")": "）"   // Closing parenthesis
        ]
        let ret = replacementRule.reduce(sentence) {
            $0.replacingOccurrences(of: $1.key, with: $1.value)
        }
        return ret
    }

    /**
     Separate a sentence into paragraphs.
     - parameter sentence: Sentence
     - returns: Array of paragraph
     */
    internal static func _separate(sentence: String) -> [String] {
        let paragraphs = sentence.components(separatedBy: lineFeed)
        return paragraphs
    }

    /**
     Combine paragraphs into a sentence.
     - parameter paragraphs: Array of paragraph
     - returns: Sentence
     */
    internal static func _combine(paragraphs: [String]) -> String {
        var sentence: String = ""
        for (index, paragraph) in paragraphs.enumerated() {
            sentence += paragraph
            if index != paragraphs.endIndex - 1 {
                sentence += lineFeed
            }
        }
        return sentence
    }

    /**
     Delete a space located the end of the paragraph.
     - parameter paragraph: Paragraph
     - returns: Paragraph
     */
    internal static func _deleteEndSpace(paragraph: String) -> String {
        if paragraph.isEmpty {
            return paragraph
        }
        var ret: String = ""
        let lastCharacter = paragraph.suffix(1)
        if lastCharacter == fullWidthWhiteSpace {
            ret = String(paragraph.prefix(paragraph.count - 1))
        } else {
            ret = paragraph
        }
        return ret
    }

    /**
     Check whether the paragraph is dialog or not.
     - parameter paragraph: Paragraph
     - returns: true: Dialog / false: Not dialog
     */
    internal static func _checkDialogParagraph(paragraph: String) -> Bool {
        if paragraph.isEmpty {
            return false
        }
        var ret: Bool = false
        let firstCharacter = paragraph.prefix(1)
        if firstCharacter == "「" || firstCharacter == "『" || firstCharacter == "（" || firstCharacter == "―" {
            ret = true
        }
        return ret
    }

    /**
     Check whether the paragraph is indented or not.
     - parameter paragraph: Paragraph
     - returns: true: Indented / false: Not indented
     */
    internal static func _checkIndented(paragraph: String) -> Bool {
        if paragraph.isEmpty {
            return false
        }
        var ret: Bool = false
        let firstCharacter = paragraph.prefix(1)
        if firstCharacter == fullWidthWhiteSpace {
            ret = true
        }
        return ret
    }

    /**
     Indent the paragraph.
     - parameter paragraph: Paragraph
     - returns: Indented paragraph
     */
    internal static func _indent(paragraph: String) -> String {
        return fullWidthWhiteSpace + paragraph
    }

}
