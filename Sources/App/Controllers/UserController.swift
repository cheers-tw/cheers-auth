//
//  UserController.swift
//  cheers-gateway
//
//  Created by Dong on 3/27/24.
//  Copyright © 2024 Dongdong867. All rights reserved.
//

import Fluent
import Vapor

// MARK: - UserController

struct UserController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let user = routes.grouped("user")
        
        user.grouped(User.authenticator())
            .on(.GET, "login", body: .collect(maxSize: "500kb"), use: login)
        
        user.on(.POST, "register", body: .collect(maxSize: "1mb"), use: register)
        
        user.grouped(AccessToken.authenticator())
            .on(.POST, "rankings", use: writeRanking)
        
        user.grouped(AccessToken.authenticator())
            .on(.GET, "search", ":userId", use: searchUser)
    }
}

extension UserController {
    private func login(req: Request) async throws -> User.LoginResponse {
        let user = try req.auth.require(User.self)
        
        var token = try await AccessToken
            .query(on: req.db(.psql))
            .filter(\.$user.$id == user.id!)
            .first()
        
        if token == nil {
            token = try user.generateAccessToken()
        }
        
        try await token!.save(on: req.db(.psql))
        return User.LoginResponse(accessToken: token!.token, userId: user.id!)
    }
    
    private func register(req: Request) async throws -> Response {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        
        let token: AccessToken
        let userId = UUID()
        
        do {
            let user = try User(
                id: userId,
                account: create.account,
                hashedPassword: Bcrypt.hash(create.password),
                mail: create.mail,
                name: create.name,
                birthString: create.birth
            )
            
            try await user.save(on: req.db(.psql))
            token = try user.generateAccessToken()
            try await token.save(on: req.db(.psql))
        } catch let err {
            req.logger.error("\(String(reflecting: err))")
            throw Abort(.badRequest, reason: "\(err)")
        }
        
        let loginResponse = User.LoginResponse(accessToken: token.token, userId: userId)
        guard let loginResponseData = try? JSONEncoder().encode(loginResponse)
        else { throw Abort(.internalServerError) }
        
        return Response(status: .created, body: .init(data: loginResponseData))
    }
    
    private func writeRanking(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        let payload = try req.content.decode(UserPreference.Payload.self)
        
        let userPreferenceModel = try UserPreference.toUserPreferenceModel(
            payload.rankings,
            userId: user.requireID()
        )
        
        guard let existedPreference = try await UserPreference
            .query(on: req.db(.psql))
            .filter(\.$id == user.requireID())
            .first()
        else {
            try await userPreferenceModel.save(on: req.db(.psql))
            return Response(status: .created)
        }
        
        existedPreference.updatingFromPayload(payload: payload.rankings)
        try await existedPreference.save(on: req.db(.psql))
        
        return Response(status: .ok)
    }
    
    private func searchUser(req: Request) async throws -> [User.Get] {
        let user = try req.auth.require(User.self)
        let searchTerm = req.parameters.get("userId")!
        
        let result = try await User
            .query(on: req.db(.psql))
            .filter(\.$account == searchTerm)
            .all()
        
        return result.map {
            User.Get(id: $0.id!, account: $0.account, mail: $0.mail, name: $0.name)
        }
    }
}
