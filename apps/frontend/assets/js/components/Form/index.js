import React, { Component } from "react"
import PropTypes from "prop-types"

class Form extends Component {
    constructor(props) {
        super(props)
    }

  submitHandler = e => {
      e.preventDefault()
      this.props.submit()
  }

  render() {
      return (
          <form
              ref={form => (this.formEl = form)}
              onSubmit={this.submitHandler}
              className={this.props.className}
          >
              {this.props.children}
          </form>
      )
  }
}

Form.propTypes = {
    children: PropTypes.node,
    submit: PropTypes.func.isRequired
}

export default Form
