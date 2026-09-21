// swift-tools-version: 5.9
//
//  Package.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 5/11/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "KitoEmptyStates",
    platforms: [.iOS(.v17)],
    products: [.library(name: "KitoEmptyStates", targets: ["KitoEmptyStates"])],
    dependencies: [
        .package(url: "https://github.com/WykSofts-Inc/KitoCore.git", from: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoLoaders.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "KitoEmptyStates",
            dependencies: [
                .product(name: "KitoCore", package: "KitoCore"),
                .product(name: "KitoLoaders", package: "KitoLoaders"),
            ]
        ),
        .testTarget(name: "KitoEmptyStatesTests", dependencies: ["KitoEmptyStates"]),
    ]
)
