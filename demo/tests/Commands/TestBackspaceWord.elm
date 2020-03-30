module Commands.TestBackspaceWord exposing (..)

import Array
import Expect
import RichText.Commands exposing (backspaceWord)
import RichText.Model.Element as Element
import RichText.Model.Mark exposing (mark)
import RichText.Model.Node
    exposing
        ( Block
        , Children(..)
        , Inline
        , block
        , blockChildren
        , inlineChildren
        , inlineElement
        , markedText
        , plainText
        )
import RichText.Model.Selection exposing (caret, singleNodeRange)
import RichText.Model.State exposing (State, state, withSelection)
import RichText.Specs exposing (bold, doc, horizontalRule, image, paragraph)
import Test exposing (Test, describe, test)


example : State
example =
    state
        (block
            (Element.element doc [])
            (blockChildren <|
                Array.fromList
                    [ block
                        (Element.element paragraph [])
                        (inlineChildren <|
                            Array.fromList
                                [ plainText "this is an ex"
                                , markedText "ample okay" [ mark bold [] ]
                                ]
                        )
                    ]
            )
        )
        (Just <| caret [ 0, 1 ] 6)


expectedExample : State
expectedExample =
    state
        (block
            (Element.element doc [])
            (blockChildren <|
                Array.fromList
                    [ block
                        (Element.element paragraph [])
                        (inlineChildren <|
                            Array.fromList
                                [ plainText "this is an "
                                , markedText "okay" [ mark bold [] ]
                                ]
                        )
                    ]
            )
        )
        (Just <| caret [ 0, 0 ] 11)


expectedRemoveAn : State
expectedRemoveAn =
    state
        (block
            (Element.element doc [])
            (blockChildren <|
                Array.fromList
                    [ block
                        (Element.element paragraph [])
                        (inlineChildren <|
                            Array.fromList
                                [ plainText "this is ex"
                                , markedText "ample okay" [ mark bold [] ]
                                ]
                        )
                    ]
            )
        )
        (Just <| caret [ 0, 0 ] 8)


expectedRemoveThis : State
expectedRemoveThis =
    state
        (block
            (Element.element doc [])
            (blockChildren <|
                Array.fromList
                    [ block
                        (Element.element paragraph [])
                        (inlineChildren <|
                            Array.fromList
                                [ plainText "s is an ex"
                                , markedText "ample okay" [ mark bold [] ]
                                ]
                        )
                    ]
            )
        )
        (Just <| caret [ 0, 0 ] 0)


removeInline : State
removeInline =
    state
        (block
            (Element.element doc [])
            (blockChildren <|
                Array.fromList
                    [ block
                        (Element.element paragraph [])
                        (inlineChildren <|
                            Array.fromList
                                [ plainText "s is an ex"
                                , inlineElement (Element.element image []) []
                                , markedText "ample okay" [ mark bold [] ]
                                ]
                        )
                    ]
            )
        )
        (Just <| caret [ 0, 2 ] 6)


expectedRemoveInline : State
expectedRemoveInline =
    state
        (block
            (Element.element doc [])
            (blockChildren <|
                Array.fromList
                    [ block
                        (Element.element paragraph [])
                        (inlineChildren <|
                            Array.fromList
                                [ plainText "s is an ex"
                                , inlineElement (Element.element image []) []
                                , markedText "okay" [ mark bold [] ]
                                ]
                        )
                    ]
            )
        )
        (Just <| caret [ 0, 2 ] 0)


testBackspaceWord : Test
testBackspaceWord =
    describe "Tests the backspaceWord transform"
        [ test "Tests that the example case works as expected" <|
            \_ -> Expect.equal (Ok expectedExample) (backspaceWord example)
        , test "Tests that remove a word across multiple text leaves works as expected" <|
            \_ -> Expect.equal (Ok expectedRemoveAn) (backspaceWord (example |> withSelection (Just <| caret [ 0, 0 ] 11)))
        , test "Tests that remove a word stops at the beginning of a text block" <|
            \_ -> Expect.equal (Ok expectedRemoveThis) (backspaceWord (example |> withSelection (Just <| caret [ 0, 0 ] 3)))
        , test "Tests that remove a word stops at the beginning of an inline node" <|
            \_ -> Expect.equal (Ok expectedRemoveInline) (backspaceWord removeInline)
        ]
