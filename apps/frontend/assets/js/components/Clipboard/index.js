import React, { Component } from "react"
import ReactHtmlParser from "react-html-parser"
import Clipboard from "clipboard"

class ClipboardText extends Component {
    constructor(props) {
        super(props)
    }

    componentDidMount () {
        const span = this.span
        const input = this.input

        this.clipboard = new Clipboard(
            span, {
                target: () => input
            }
        )
        
        this.clipboard.on("success", (e) => {
            this.props.onCopy()
        })
    }

    componentWillUnmount() {
        this.clipboard.destroy()
    }

    render () {
        const { value } = this.props

        return (
            <div>
                <div id={this.props.idName ? this.props.idName : "cite-copy"} ref={(element) => { this.input = element }}>
                    {ReactHtmlParser(value)}
                </div>
                <span className="btn"
                    ref={(element) => { this.span = element }}
                > 
                    {this.props.copied ? "Copied to your clipboard!" : "Copy"}
                </span>
            </div>
        )
    }
}

export default ClipboardText
