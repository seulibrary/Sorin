const path = require("path")
const webpack = require("webpack")
const CopyWebpackPlugin = require("copy-webpack-plugin")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const { lstatSync, readdirSync } = require('fs')

const isDirectory = source => lstatSync(source).isDirectory()
const getDirectories = source =>
  readdirSync(source).map(name => path.join(source, name)).filter(isDirectory)

let extension_list = getDirectories(path.join(__dirname, "./js/extensions/"))

module.exports = {
    entry: [
        path.join(__dirname, "/js/index.js"),
        path.join(__dirname, "/scss/app.scss")
    ],
    output: {
        path: path.resolve(__dirname, "../priv/static/"),
        filename: "js/app.js"
    },
    resolveLoader: {
        modules: [path.join(__dirname, "node_modules")]
    },
    module: {
        rules: [
            {
                test: /\.(js|jsx)$/,
                exclude: /node_modules/,
                // include: path.join(__dirname, "assets/js"),
                use: {
                    loader: "babel-loader",
                    options: {
                        presets: ["@babel/preset-react", "@babel/preset-env"],
                        plugins: [
                            "@babel/plugin-proposal-object-rest-spread", 
                            "@babel/plugin-proposal-class-properties",
                            "@babel/plugin-syntax-dynamic-import"
                        ]
                    }
                }
            },
            {
                test: /\.(scss|css)$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    {
                        loader: "css-loader",
                        options: {
                            url: false,
                        }
                    }, {
                        loader: "postcss-loader"
                    }, {
                        loader: "sass-loader"
                    }]
            },
            {
                test: /\.(png|woff|woff2|eot|ttf|svg)$/,
                use: [
                    {
                        loader: "url-loader",
                        options: {
                            limit: 10000
                        }
                    }
                ]
            }
        ]
    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: "css/app.css",
        }),
        // Add this plugin so Webpack won't output the files when anything errors
        // during the build process
        new webpack.NoEmitOnErrorsPlugin(),
        new webpack.DefinePlugin({
            EXTERNAL_EXTENSIONS: JSON.stringify(extension_list)
        }),
        new CopyWebpackPlugin([
            { from: path.resolve(__dirname, "static/images"), to: "../static/images" },
            { from: path.resolve(__dirname, "static/favicon"), to: "../static/favicon" },
            { from: path.resolve(__dirname, "static/favicon.ico"), to: "../static/favicon.io" },
            { from: path.resolve(__dirname, "static/robots.txt"), to: "../static/robots.txt" }
        ]),
    ]
}

