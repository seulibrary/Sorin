const merge = require('webpack-merge')
const webpack = require('webpack')
const common = require('./webpack.common.js')
const TerserPlugin = require("terser-webpack-plugin")

module.exports = merge(common, {
    mode: 'production',
    optimization: {
        minimize: true,
        minimizer: [
            new TerserPlugin({
                terserOptions: {
                    parallel: true,
                    ecma: 6,
                    compress: true,
                    output: {
                        comments: false,
                        beautify: false
                    }
                }
            })
        ],
        splitChunks: {
            cacheGroups: {
                styles: {
                    name: "app",
                    test: /\.css$/,
                    chunks: "all",
                    enforce: true
                }
            }
        }
    },
    plugins: [
        new webpack.DefinePlugin({
            ENV_MODE: JSON.stringify("production")
        })
    ]

})
