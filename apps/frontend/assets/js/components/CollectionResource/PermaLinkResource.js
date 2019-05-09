import React, { Component } from "react"
import EditResource from "./EditResource"

export default class PermaLinkResource extends Component {
    constructor(props) {
        super(props)
    }

    render() {
        return (
            <div data-resource={this.props.id}>
                <EditResource index={this.props.index} id={this.props.data.id} canEdit={false} channel={this.props.channel} parent={this.props.parent} showFiles={false} {...this.props} />
            </div>
        )
    }
}