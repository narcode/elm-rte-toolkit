module RichText.Config.MarkDefinition exposing
    ( MarkDefinition, markDefinition, MarkToHtml, HtmlToMark, name, toHtmlNode, fromHtmlNode
    , defaultMarkDefinition, defaultMarkToHtml, defaultHtmlToMark
    )

{-| A mark definition describes how to encode and decode a mark.


# Mark

@docs MarkDefinition, markDefinition, MarkToHtml, HtmlToMark, name, toHtmlNode, fromHtmlNode


# Struts

@docs defaultMarkDefinition, defaultMarkToHtml, defaultHtmlToMark

-}

import Array exposing (Array)
import RichText.Internal.Definitions as Internal
import RichText.Model.Attribute exposing (Attribute(..))
import RichText.Model.HtmlNode exposing (HtmlNode(..))
import RichText.Model.Mark exposing (Mark)


{-| A mark definition defines how a mark is encoded an decoded.
-}
type alias MarkDefinition =
    Internal.MarkDefinition


{-| Type alias for a mark encoding function

    codeToHtmlNode : MarkToHtml
    codeToHtmlNode _ children =
        ElementNode "code" [] children

-}
type alias MarkToHtml =
    Mark -> Array HtmlNode -> HtmlNode


{-| Type alias for a mark decoding function

    htmlNodeToCode : HtmlToMark
    htmlNodeToCode definition node =
        case node of
            ElementNode name _ children ->
                if name == 'code' then
                    Just ( mark def [], children )

                else
                    Nothing

            _ ->
                Nothing

-}
type alias HtmlToMark =
    MarkDefinition -> HtmlNode -> Maybe ( Mark, Array HtmlNode )


{-| Defines a mark. The arguments are as follows:

  - `name` - The unique name for this mark. This should be something like 'bold' or 'link'.

  - `toHtmlNode` - The function that converts the mark to html. This is used in rendering,
    DOM validation, and path translation.

  - `fromHtmlNode` - The function that converts html to marks. This is used in things
    like paste to determine the editor nodes from html.

```
    code : MarkDefinition
    code =
        markDefinition {name="code", toHtmlNode=codeToHtmlNode, fromHtmlNode=htmlNodeToCode}
```

-}
markDefinition :
    { name : String
    , toHtmlNode : MarkToHtml
    , fromHtmlNode : HtmlToMark
    }
    -> MarkDefinition
markDefinition contents =
    Internal.MarkDefinition
        contents


{-| Name of the mark this mark definition defines.

    name code
    --> "code"

-}
name : MarkDefinition -> String
name definition_ =
    case definition_ of
        Internal.MarkDefinition c ->
            c.name


{-| Function which encodes a mark to Html
-}
toHtmlNode : MarkDefinition -> MarkToHtml
toHtmlNode definition_ =
    case definition_ of
        Internal.MarkDefinition c ->
            c.toHtmlNode


{-| Function which decodes a mark from Html
-}
fromHtmlNode : MarkDefinition -> HtmlToMark
fromHtmlNode definition_ =
    case definition_ of
        Internal.MarkDefinition c ->
            c.fromHtmlNode


{-| Creates a mark definition which assumes the name of the mark is the same as the name of the
html node.

    defaultMarkDefinition "b"
    --> definition which encodes to <b>...</b> and decodes from "<b>...</b>"

-}
defaultMarkDefinition : String -> MarkDefinition
defaultMarkDefinition name_ =
    markDefinition
        { name = name_
        , toHtmlNode = defaultMarkToHtml name_
        , fromHtmlNode = defaultHtmlToMark name_
        }


{-| Creates an `MarkToHtml` function that will encode a mark to html with the same name as the mark.

    defaultMarkToHtml "b"
    --> returns a function which encodes to "<b>...</b>"

-}
defaultMarkToHtml : String -> MarkToHtml
defaultMarkToHtml tag mark_ children =
    ElementNode tag
        (List.filterMap
            (\attr ->
                case attr of
                    StringAttribute k v ->
                        Just ( k, v )

                    _ ->
                        Nothing
            )
            (Internal.attributesFromMark mark_)
        )
        children


{-| Creates an `HtmlToMark` function that will decode a mark from the tag name specified.

    defaultHtmlToMark "b"
    --> returns a function which decodes from "<b>...</b>"

-}
defaultHtmlToMark : String -> HtmlToMark
defaultHtmlToMark htmlTag def node =
    case node of
        ElementNode name_ _ children ->
            if name_ == htmlTag then
                Just ( Internal.mark def [], children )

            else
                Nothing

        _ ->
            Nothing
