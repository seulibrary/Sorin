import React, { Component } from "react"
import PropTypes from "prop-types"

class Accordion extends Component {
    constructor(props) {
        super(props)
        this.state = {
            open: false
        }

        this.labelRef = React.createRef()
    }

    handleClick = (e) => {
        this.setState({
            open: !this.state.open
        })
    }

    render() {        
        return (
            <div className="accordion">
                <label ref={this.labelRef} className={this.props.titleClass} onClick={this.handleClick}>
                    {this.props.symbolPosition == "left" ? 
                        <span>
                            {this.state.open ? "- " : "+ "}
                        </span>
                        : ""}
                    {this.props.title}
                    {this.props.symbolPosition != "left" ? 
                        <span>
                            {this.state.open ? " -" : " +"}
                        </span>
                        : ""}
                </label>
                <div className={this.state.open ? "open" : "closed"}>
                    { this.props.children }
                </div>
            </div>
        )
    }
}

Accordion.propTypes = {
    children: PropTypes.node,
    title: PropTypes.string,
    titleClass: PropTypes.string
}

export default Accordion