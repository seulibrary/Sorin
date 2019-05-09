import React, { Component } from "react"

export default class TypeSelect extends Component {

    renderSelect(name, value) {
        return (
            <option value={value} key={"value-" + value}>{name}</option>
        )
    }

    onChange = (e) => {
        this.props.onChange(e.target.value)
    }

    render() {
        let options = []
        
        this.props.options.forEach(option => {
            if (Array.isArray(option)) {
                options.push(this.renderSelect(option[0], option[1]))
            } else {
                options.push(this.renderSelect(option, option))
            }
        })

        return (
            <select defaultValue={this.props.selected} onChange={this.onChange}>
                {options}
            </select>
        )
    }
}