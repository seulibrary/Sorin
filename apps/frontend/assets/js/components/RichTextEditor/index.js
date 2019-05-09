import React, { Component } from "react"
import { 
    Editor, 
    RichUtils, 
    EditorState, 
    ContentState, 
    getDefaultKeyBinding, 
    convertToRaw, 
    convertFromRaw
} from "draft-js"

export default class RichTextEditor extends Component {
    constructor(props) {
        super(props)
        
        this.state = {
            editorState: ""
        }

        if (this.isJson(this.props.data)) {
            this.state.editorState = EditorState.createWithContent(convertFromRaw(JSON.parse(this.props.data)))
        } else if (this.props.data) {
            this.state.editorState = EditorState.createWithContent(ContentState.createFromText(this.props.data))
        } else {
            this.state.editorState = EditorState.createEmpty()
        }

        this.focus = () => this.refs.editor.focus()

        this.handleKeyCommand = this._handleKeyCommand.bind(this)
        this.mapKeyToEditorCommand = this._mapKeyToEditorCommand.bind(this)
        this.toggleBlockType = (type) => this._toggleBlockType(type)
        this.toggleInlineStyle = (style) => this._toggleInlineStyle(style)
    }

    isJson = (str) => {
        try {
            JSON.parse(str)
        } catch (e) {
            return false
        }
        return true
    }

    onNotesChange = (editorState) => {
        const contentState = editorState.getCurrentContent()
        const content = JSON.stringify(convertToRaw(contentState))

        this.props.onChange(this.props.id, content)
        this.setState({
            editorState,
        })
    }

    _handleKeyCommand(command, editorState) {
        const newState = RichUtils.handleKeyCommand(editorState, command)

        if (newState) {
            this.onNotesChange(newState)
            return true
        }
        return false
    }

    _mapKeyToEditorCommand(e) {
        return getDefaultKeyBinding(e)
    }

    _toggleBlockType(blockType) {
        this.onNotesChange(
            RichUtils.toggleBlockType(
                this.state.editorState,
                blockType
            )
        )
    }

    _toggleInlineStyle(inlineStyle) {
        this.onNotesChange(
            RichUtils.toggleInlineStyle(
                this.state.editorState,
                inlineStyle
            )
        )
    }

    getBlockStyle = (block) => {
        switch (block.getType()) {
        case "blockquote":
            return "RichEditor-blockquote"
        default:
            return null
        }
    }

    handleTab = (event) => {
        const newEditorState = RichUtils.onTab(event, this.state.editorState, 4)

        if (newEditorState !== this.state.editorState) {
            this.onNotesChange(newEditorState)
        }
    }

    render() {
        const editorState = this.state.editorState
        var contentState = editorState.getCurrentContent()
        let className = ""

        if (!contentState.hasText()) {
            if (contentState.getBlockMap().first().getType() !== "unstyled") {
                className += " DraftEditor-hidePlaceholder"
            }
        }

        return (
            <div className="DraftEditor-root" onClick={this.focus}>
                {this.props.writeAccess ? 
                    <div className="editor-controls">
                        <BlockStyleControls
                            editorState={editorState}
                            onToggle={this.toggleBlockType}
                        />

                        <InlineStyleControls
                            editorState={editorState}
                            onToggle={this.toggleInlineStyle}
                        />
                    </div>
                    : ""}

                <div className={className}>
                    <Editor
                        readOnly={!this.props.writeAccess}
                        blockStyleFn={this.getBlockStyle}
                        customStyleMap={styleMap}
                        editorState={editorState}
                        handleKeyCommand={this.handleKeyCommand}
                        stripPastedStyles={true}
                        keyBindingFn={this.mapKeyToEditorCommand}
                        onTab={this.handleTab}
                        onChange={this.onNotesChange}
                        placeholder={!this.props.writeAccess && !contentState.hasText() ? "No notes available..." : "Notes..."}
                        spellCheck={true}
                        ref="editor"
                    />
                </div>
            </div>
        )
    }
}

const styleMap = {
    DefaultDraftInlineStyle: {
        color: "red"
    },
    CODE: {
        backgroundColor: "rgba(0, 0, 0, 0.05)",
        fontFamily: "\"Inconsolata\", \"Menlo\", \"Consolas\", monospace",
        fontSize: 16,
        padding: 2,
    },
}

class StyleButton extends Component {
    constructor() {
        super()
        this.onToggle = (e) => {
            e.preventDefault()
            e.stopPropagation()
            this.props.onToggle(this.props.style)
        }
    }

    render() {
        let className = "DraftEditor-styleButton"

        if (this.props.active) {
            className += " DraftEditor-activeButton"
        }
        return (
      
            <span className={className} onMouseDown={this.onToggle}>
                {this.props.label}
            </span>
      
        )
    }
}

const BLOCK_TYPES = [
    {label: "H1", style: "header-one"},
    {label: "H2", style: "header-two"},
    {label: "H3", style: "header-three"},
    {label: "Blockquote", style: "blockquote"},
    {label: "UL", style: "unordered-list-item"},
    {label: "OL", style: "ordered-list-item"}
]

const BlockStyleControls = (props) => {
    const {editorState} = props
    const selection = editorState.getSelection()
    const blockType = editorState
        .getCurrentContent()
        .getBlockForKey(selection.getStartKey())
        .getType()

    return (
        <div className="DraftEditor-controls">
            {BLOCK_TYPES.map((type) =>
                <StyleButton
                    key={type.label}
                    active={type.style === blockType}
                    label={type.label}
                    onToggle={props.onToggle}
                    style={type.style}
                />
            )}
        </div>
    )
}

const INLINE_STYLES = [
    {label: "Bold", style: "BOLD"},
    {label: "Italic", style: "ITALIC"},
    {label: "Underline", style: "UNDERLINE"},
    {label: "Monospace", style: "CODE"},
]
const InlineStyleControls = (props) => {
    const currentStyle = props.editorState.getCurrentInlineStyle()
  
    return (
        <div className="DraftEditor-controls">
            {INLINE_STYLES.map((type) =>
                <StyleButton
                    key={type.label}
                    active={currentStyle.has(type.style)}
                    label={type.label}
                    onToggle={props.onToggle}
                    style={type.style}
                />
            )}
        </div>
    )
}
