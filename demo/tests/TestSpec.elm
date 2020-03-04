module TestSpec exposing (..)

import Array exposing (Array)
import Expect
import Rte.Model exposing (ChildNodes(..), ContentType(..), EditorFragment(..), EditorInlineLeaf(..), ElementParameters, HtmlNode(..), Mark, Spec, inlineLeafArray)
import Rte.Spec exposing (htmlToElementArray)
import Set
import SimpleSpec exposing (simpleSpec)
import Test exposing (Test, describe, test)


oneParagraph =
    "<p>test</p>"


expectedOneParagraph =
    Array.fromList <|
        [ BlockNodeFragment <|
            Array.fromList
                [ { parameters =
                        { name = "paragraph"
                        , attributes = []
                        , annotations = Set.empty
                        }
                  , childNodes =
                        inlineLeafArray
                            (Array.fromList
                                [ TextLeaf { text = "test", marks = [], annotations = Set.empty }
                                ]
                            )
                  }
                ]
        ]


twoParagraphs =
    "<p>test1</p><p>test2</p>"


twoParagraphsBlockFragment =
    Array.fromList
        [ { parameters =
                { name = "paragraph"
                , attributes = []
                , annotations = Set.empty
                }
          , childNodes =
                inlineLeafArray
                    (Array.fromList
                        [ TextLeaf { text = "test1", marks = [], annotations = Set.empty }
                        ]
                    )
          }
        , { parameters =
                { name = "paragraph"
                , attributes = []
                , annotations = Set.empty
                }
          , childNodes =
                inlineLeafArray
                    (Array.fromList
                        [ TextLeaf { text = "test2", marks = [], annotations = Set.empty }
                        ]
                    )
          }
        ]


expectedTwoParagraphs =
    Array.fromList <|
        [ BlockNodeFragment <| twoParagraphsBlockFragment ]


justText =
    "test"


justTextInlineFragment =
    Array.fromList
        [ TextLeaf { text = "test", marks = [], annotations = Set.empty }
        ]


expectedJustText =
    Array.fromList
        [ InlineLeafFragment <| justTextInlineFragment ]


codeAndParagraphs =
    "<pre><code><p>test1</p><p>test2</p></code></pre>"


expectedCodeWithParagraphs =
    Array.fromList
        [ BlockNodeFragment <|
            Array.fromList
                [ { parameters =
                        { name = "code_block"
                        , attributes = []
                        , annotations = Set.empty
                        }
                  , childNodes =
                        BlockArray <| twoParagraphsBlockFragment
                  }
                ]
        ]


testHtmlToElementArray : Test
testHtmlToElementArray =
    describe "Tests that htmlToElementArray works as expected"
        [ test "Tests that a basic paragraph can be parsed" <|
            \_ -> Expect.equal (Ok expectedOneParagraph) (htmlToElementArray simpleSpec oneParagraph)
        , test "Tests that multiple paragraphs can be parsed" <|
            \_ -> Expect.equal (Ok expectedTwoParagraphs) (htmlToElementArray simpleSpec twoParagraphs)
        , test "Tests that simple text content can be parsed" <|
            \_ -> Expect.equal (Ok expectedJustText) (htmlToElementArray simpleSpec justText)
        , test "Tests that paragraphs wrapped in a code block can be parsed" <|
            \_ -> Expect.equal (Ok expectedCodeWithParagraphs) (htmlToElementArray simpleSpec codeAndParagraphs)
        ]
