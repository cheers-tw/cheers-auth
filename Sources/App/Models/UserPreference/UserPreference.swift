//
//  UserPreference.swift
//
//
//  Created by 楊晏禎 on 2024/10/24.
//

import Fluent
import Vapor

// MARK: - RankingPayload

struct RankingPayload: Content {
    let userId: String
    let rankings: [RankingEntry]
}

// MARK: - RankingEntry

struct RankingEntry: Content {
    let food: String
    let score: Int
}

// MARK: - UserPreference

final class UserPreference: Model, Content, @unchecked Sendable {
    static let schema = "user_preference"

    enum Category: String, Codable, CaseIterable {
        case american, chinese, dessert, japanese, vietnamese, italian, korean, hongkong, thai, french, western, southeastAsian, exotic, bar
    }

    @ID(custom: "user_id", generatedBy: .user)
    var id: UUID?

    @Field(key: "american")
    var american: Int

    @Field(key: "chinese")
    var chinese: Int

    @Field(key: "dessert")
    var dessert: Int

    @Field(key: "japanese")
    var japanese: Int

    @Field(key: "vietnamese")
    var vietnamese: Int

    @Field(key: "italian")
    var italian: Int

    @Field(key: "korean")
    var korean: Int

    @Field(key: "hongkong")
    var hongkong: Int

    @Field(key: "thai")
    var thai: Int

    @Field(key: "french")
    var french: Int

    @Field(key: "western")
    var western: Int

    @Field(key: "southeastAsian")
    var southeastAsian: Int

    @Field(key: "exotic")
    var exotic: Int

    @Field(key: "bar")
    var bar: Int

    init() {}

    init(userId: UUID, rankings: [RankingEntry]) {
        self.id = userId
        self.american = rankings.first(where: { $0.food == "美式" })?.score ?? 0
        self.chinese = rankings.first(where: { $0.food == "中式" })?.score ?? 0
        self.dessert = rankings.first(where: { $0.food == "甜點" })?.score ?? 0
        self.japanese = rankings.first(where: { $0.food == "日式" })?.score ?? 0
        self.vietnamese = rankings.first(where: { $0.food == "越式" })?.score ?? 0
        self.italian = rankings.first(where: { $0.food == "義式" })?.score ?? 0
        self.korean = rankings.first(where: { $0.food == "韓式" })?.score ?? 0
        self.hongkong = rankings.first(where: { $0.food == "港式" })?.score ?? 0
        self.thai = rankings.first(where: { $0.food == "泰式" })?.score ?? 0
        self.french = rankings.first(where: { $0.food == "法式" })?.score ?? 0
        self.western = rankings.first(where: { $0.food == "西式" })?.score ?? 0
        self.southeastAsian = rankings.first(where: { $0.food == "東南亞" })?.score ?? 0
        self.exotic = rankings.first(where: { $0.food == "異國料理" })?.score ?? 0
        self.bar = rankings.first(where: { $0.food == "酒吧" })?.score ?? 0
    }

    init(userId: UUID, preferences: [UserPreference.Category: Int]) {
        self.id = userId
        self.createOrUpdateModel(preferences: preferences)
    }

    func createOrUpdateModel(preferences: [UserPreference.Category: Int]) {
        self.american = preferences[.american] ?? 0
        self.chinese = preferences[.chinese] ?? 0
        self.dessert = preferences[.dessert] ?? 0
        self.japanese = preferences[.japanese] ?? 0
        self.vietnamese = preferences[.vietnamese] ?? 0
        self.italian = preferences[.italian] ?? 0
        self.korean = preferences[.korean] ?? 0
        self.hongkong = preferences[.hongkong] ?? 0
        self.thai = preferences[.thai] ?? 0
        self.french = preferences[.french] ?? 0
        self.western = preferences[.western] ?? 0
        self.southeastAsian = preferences[.southeastAsian] ?? 0
        self.exotic = preferences[.exotic] ?? 0
        self.bar = preferences[.bar] ?? 0
    }
    
    
}
