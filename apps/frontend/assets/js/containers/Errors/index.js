import React, { Component } from "react"

export default class ErrorBoundary extends Component {
    constructor(props) {
        super(props)
        this.state = { 
            error: null,
            errorInfo: null
        }
    }
  
    componentDidCatch(error, info) {
        this.setState({
            error: error,
            errorInfo: info
        })
    }
  
    render() {
        if (this.state.error) {
        // You can render any custom fallback UI
            return (
                <div>
                    <h1>Sorry, something went wrong.</h1>
                    <p>Error: {this.state.error && this.state.error.toString()}</p>
                </div>
            )
        }
  
        return this.props.children 
    }
}