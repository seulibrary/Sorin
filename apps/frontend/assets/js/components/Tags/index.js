import React, { Component } from "react"
import TagsInput from "react-tagsinput"

export default class Tags extends Component {
    constructor(props) {
        super(props)
        this.state = {tag: ""}
    }

    handleChange = (tags, changed) => {
        this.props.onChange(tags, changed)
    }

    defaultRenderLayout = (tagComponents, inputComponent) => {
        return (
            <span>
                {this.props.disabled ?
                    "" : inputComponent}
                {tagComponents}
            </span>
        )
    }

    defaultRenderInput = ({addTag, ...props}) => {
        let {onChange, value, ...other} = props

        return (
            <input type='text' onChange={onChange} value={value.toUpperCase()} {...other} />
        )
    }

    componentWillUnmount() {
        this.refs.tags.accept()
    }

    handleChangeInput = (tag) => {
        this.setState({tag: tag.toUpperCase()})
    }

    render() {
        return (
            <TagsInput
                ref="tags"
                renderLayout={this.defaultRenderLayout}
                renderInput={this.defaultRenderInput}
                value={this.props.data}
                onChange={this.handleChange}
                inputValue={this.state.tag}
                onChangeInput={this.handleChangeInput}
                onlyUnique
                addKeys={[9, 13, 188]}
                disabled={this.props.disabled || false}
            />
        )
    }
}
