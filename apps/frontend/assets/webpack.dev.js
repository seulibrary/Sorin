const merge = require('webpack-merge')
const webpack = require('webpack')
const common = require('./webpack.common.js')
const TerserPlugin = require("terser-webpack-plugin")

module.exports = merge(common, {
    mode: 'development',
    devtool: "source-map",
    watchOptions: {
        poll: 1000,
        ignored: /node_modules/
    },
    optimization: {
        minimize: false,

        minimizer: [
            new TerserPlugin({
                terserOptions: {
                    parallel: true,
                    ecma: 6,
                    compress: false,
                    output: {
                        comments: false,
                        beautify: false
                    }
                }
            })
        ],
    },
    plugins: [
        new webpack.DefinePlugin({
            ENV_MODE: JSON.stringify("development")
        })
    ]
})
