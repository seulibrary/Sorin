import React from "react"
import Slider, {Range} from "rc-slider"

const RangeWithTooltip = Slider.createSliderWithTooltip(Range)

class ReduxSlider extends React.Component {
    constructor(props) {
        super(props)
    }

    onChange = (e) => {
        let data = []

        if (e.target.name == "minYear") {
            data = [parseInt(e.target.value) || "", this.props.inputValue[1]]
        } else {
            data = [this.props.inputValue[0], parseInt(e.target.value) || ""]
        }

        if (data.length > 0) {
            this.props.onChange(data)
        }
    }

    render() {
        
        const year = (new Date()).getFullYear()

        return (
            <div>
                <RangeWithTooltip
                    value={this.props.inputValue}
                    min={1000}
                    max={year}
                    onChange={newVal => this.props.onChange(newVal)}
                    onAfterChange={newVal => this.props.onChange(newVal)}
                    {...this.props}
                />

                <label>Years: </label>
                <input type="number" name="minYear" min="1000" max={this.props.inputValue[1]} value={this.props.inputValue[0]} onChange={this.onChange} />
                to <input type="number" name="maxYear" min={this.props.inputValue[0]} value={this.props.inputValue[1]} onChange={this.onChange} />
            </div>
        )
    }
}

export default ReduxSlider