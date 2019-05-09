import React, { Component } from "react"

export default class Loader extends Component {
    constructor(props) {
        super(props)
    }

    loader() {
        return (
            <div className="loader" style={ this.props.styles }>
                {this.props.text? this.props.text : "Loading..."}
            </div>
        )
    }

    render() {  
        if (this.props.children) {
            return (
                <div>
                    {
                        this.props.isVisible ?
                            this.loader()
                            :
                            this.props.children
                    }
                </div>
            )
        } else {
            return (
                <React.Fragment>
                    {this.props.isVisible ? this.loader() : null}
                </React.Fragment> 
            )
        }
    }
}