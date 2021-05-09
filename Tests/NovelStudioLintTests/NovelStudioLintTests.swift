//--------------------------------------------------------------------------//
// NovelStudioLint - NovelStudioLintTests.swift
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

import XCTest
@testable import NovelStudioLint

final class NovelStudioLintTests: XCTestCase {

    // MARK: - Utility Tests

    func testPreprocess() {
        let testcase = "｢小説 ()｣"
        let expected = "「小説　（）」"

        let result = NovelStudioLint._preprocess(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

    func testSeparateAndCombine() {
        let sentence = "古池や\n蛙飛びこむ\n水の音"
        let expected = ["古池や", "蛙飛びこむ", "水の音"]

        let paragraphs = NovelStudioLint._separate(sentence: sentence)
        XCTAssertEqual(paragraphs.count, 3)
        XCTAssertEqual(paragraphs[0], expected[0])
        XCTAssertEqual(paragraphs[1], expected[1])
        XCTAssertEqual(paragraphs[2], expected[2])

        let combined = NovelStudioLint._combine(paragraphs: paragraphs)
        XCTAssertEqual(combined, sentence)
    }

    func testDeleteEndSpaceForEmpty() {
        let testcase = ""
        let expected = ""

        let result = NovelStudioLint._deleteEndSpace(paragraph: testcase)
        XCTAssertEqual(result, expected)
    }

    func testDeleteEndSpaceForOnlySpace() {
        let testcase = "　"
        let expected = ""

        let result = NovelStudioLint._deleteEndSpace(paragraph: testcase)
        XCTAssertEqual(result, expected)
    }

    func testDeleteEndSpaceForSpace() {
        let testcase = "小説　"
        let expected = "小説"

        let result = NovelStudioLint._deleteEndSpace(paragraph: testcase)
        XCTAssertEqual(result, expected)
    }

    func testDeleteEndSpaceForNoSpace() {
        let testcase = "小説"
        let expected = "小説"

        let result = NovelStudioLint._deleteEndSpace(paragraph: testcase)
        XCTAssertEqual(result, expected)
    }

    func testCheckDialogParagraph() {
        XCTAssertEqual(NovelStudioLint._checkDialogParagraph(paragraph: ""), false)
        XCTAssertEqual(NovelStudioLint._checkDialogParagraph(paragraph: "　"), false)
        XCTAssertEqual(NovelStudioLint._checkDialogParagraph(paragraph: "小説"), false)
        XCTAssertEqual(NovelStudioLint._checkDialogParagraph(paragraph: "「小説」"), true)
        XCTAssertEqual(NovelStudioLint._checkDialogParagraph(paragraph: "『小説』"), true)
        XCTAssertEqual(NovelStudioLint._checkDialogParagraph(paragraph: "（小説）"), true)
        XCTAssertEqual(NovelStudioLint._checkDialogParagraph(paragraph: "――小説"), true)
    }

    func testCheckIndented() {
        XCTAssertEqual(NovelStudioLint._checkIndented(paragraph: ""), false)
        XCTAssertEqual(NovelStudioLint._checkIndented(paragraph: "　"), true)
        XCTAssertEqual(NovelStudioLint._checkIndented(paragraph: "小説"), false)
        XCTAssertEqual(NovelStudioLint._checkIndented(paragraph: "　「小説」"), true)
    }

    func testIndent() {
        let testcase = "小説"
        let expected = "　小説"

        let result = NovelStudioLint._indent(paragraph: testcase)
        XCTAssertEqual(result, expected)
    }

    func testInsertSpace() {
        XCTAssertEqual(NovelStudioLint._insertSpace(paragraph: "粉砕！玉砕！大喝采！"), "粉砕！　玉砕！　大喝采！　")
        XCTAssertEqual(NovelStudioLint._insertSpace(paragraph: "粉砕？玉砕？大喝采？"), "粉砕？　玉砕？　大喝采？　")
        XCTAssertEqual(NovelStudioLint._insertSpace(paragraph: "粉砕!玉砕!大喝采!"), "粉砕!　玉砕!　大喝采!　")
        XCTAssertEqual(NovelStudioLint._insertSpace(paragraph: "粉砕?玉砕?大喝采?"), "粉砕?　玉砕?　大喝采?　")
        XCTAssertEqual(NovelStudioLint._insertSpace(paragraph: "粉砕‼玉砕‼大喝采‼"), "粉砕‼　玉砕‼　大喝采‼　")
        XCTAssertEqual(NovelStudioLint._insertSpace(paragraph: "粉砕⁉玉砕⁉大喝采⁉"), "粉砕⁉　玉砕⁉　大喝采⁉　")
        XCTAssertEqual(NovelStudioLint._insertSpace(paragraph: "粉砕⁈玉砕⁈大喝采⁈"), "粉砕⁈　玉砕⁈　大喝采⁈　")
        XCTAssertEqual(NovelStudioLint._insertSpace(paragraph: "粉砕⁇玉砕⁇大喝采⁇"), "粉砕⁇　玉砕⁇　大喝采⁇　")
    }

    func testDeleteUnnecessarySpace() {
        XCTAssertEqual(NovelStudioLint._deleteUnnecessarySpace(paragraph: "粉砕　！玉砕　！　大喝采！　　"), "粉砕！玉砕！　大喝采！　")
    }

    func testDeleteSpaceBeforeOpeningBracket() {
        let testcase = "　「小説」"
        let expected = "「小説」"

        let result = NovelStudioLint._deleteSpaceBeforeOpeningBracket(paragraph: testcase)
        XCTAssertEqual(result, expected)
    }

    func testDeletePunctuationBeforeClosingBracket() {
        let testcase = "「小説。」"
        let expected = "「小説」"

        let result = NovelStudioLint._deletePunctuationBeforeClosingBracket(paragraph: testcase)
        XCTAssertEqual(result, expected)
    }

    // MARK: - API Tests

    func testDeleteEndSpaces() {
        let testcase = "古池や　\n蛙飛びこむ　　\n水の音　　　"
        let expected = "古池や\n蛙飛びこむ\n水の音"

        let result = NovelStudioLint.deleteEndSpaces(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

    func testInsertIndent() {
        let testcase = "古池や\n「蛙飛びこむ」\n　水の音"
        let expected = "　古池や\n「蛙飛びこむ」\n　水の音"

        let result = NovelStudioLint.insertIndent(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

    func testInsertSpaceAfterReservedMarks() {
        let testcase = "古池！や！\n「蛙飛びこむ！？」\n水？　の音！！　"
        let expected = "古池！　や！\n「蛙飛びこむ！？」\n水？　の音！！"

        let result = NovelStudioLint.insertSpaceAfterReservedMarks(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

    func testDeleteSpacesBeforeOpeningBracket() {
        let testcase = "　古池や\n　「蛙飛びこむ」\n　　「水の音」"
        let expected = "　古池や\n「蛙飛びこむ」\n「水の音」"

        let result = NovelStudioLint.deleteSpacesBeforeOpeningBracket(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

    func testDeletePunctuationsBeforeClosingBracket() {
        let testcase = "「古池や、」\n「蛙飛びこむ。」\n「水の音。。」"
        let expected = "「古池や」\n「蛙飛びこむ」\n「水の音」"

        let result = NovelStudioLint.deletePunctuationsBeforeClosingBracket(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

    func testTransformFullWidthToHalfEmpty() {
        let testcase = ""
        let expected = ""

        let result = NovelStudioLint.transformFullWidthToHalf(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

    func testTransformFullWidthToHalfWhiteSpace() {
        let testcase = " "
        let expected = "　"

        let result = NovelStudioLint.transformFullWidthToHalf(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

    func testTransformFullWidthToHalf() {
        let testcase = "123ＡＢＣ"
        let expected = "１２３ＡＢＣ"

        let result = NovelStudioLint.transformFullWidthToHalf(sentence: testcase)
        XCTAssertEqual(result, expected)
    }

}
