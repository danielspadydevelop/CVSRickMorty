//
//  RickAndMortyAPIServiceTests.swift
//  CVSRickMortyTests
//
//  Created by Daniel Spady on 9/9/26.
//

@testable import CVSRickMorty
import Foundation
import Testing

@Suite(.serialized)
struct RickAndMortyAPIServiceTests {

    private final class MockURLProtocol: URLProtocol {
        static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?

        override class func canInit(with request: URLRequest) -> Bool { true }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            guard let handler = MockURLProtocol.requestHandler else {
                fatalError("MockURLProtocol.requestHandler was not set.")
            }
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() {}
    }

    private func makeService() -> RickAndMortyAPIService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return RickAndMortyAPIService(session: URLSession(configuration: configuration))
    }

    @Test("Returns decoded characters and percent-encodes the search name in the query")
    func returnsDecodedCharacters() async throws {
        let responseJSON = """
            { "results": [\(TestFixtures.characterJSON)] }
            """
        let responseData = try #require(responseJSON.data(using: .utf8))
        var requestedURL: URL?
        MockURLProtocol.requestHandler = { request in
            requestedURL = request.url
            guard let url = request.url else {
                throw URLError(.badURL)
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw URLError(.badServerResponse)
            }
            return (response, responseData)
        }

        let query = CharacterQuery(name: "rick sanchez")
        let characters = try await makeService().searchCharacters(matching: query)

        #expect(characters.count == 1)
        #expect(characters.first?.name == "Rick Sanchez")
        #expect(characters.first?.species == "Human")
        #expect(characters.first?.origin.name == "Earth (C-137)")
        #expect(requestedURL?.query == "name=rick%20sanchez")
    }

    @Test("Encodes status, species, and type filters into the query")
    func encodesFilterParameters() async throws {
        var requestedURL: URL?
        MockURLProtocol.requestHandler = { request in
            requestedURL = request.url
            guard let url = request.url,
                  let response = HTTPURLResponse(
                    url: url,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                  ) else {
                throw URLError(.badServerResponse)
            }
            return (response, Data("{ \"results\": [] }".utf8))
        }

        let query = CharacterQuery(
            name: "rick",
            status: "alive",
            species: "Human",
            type: "Genetic experiment"
        )
        _ = try await makeService().searchCharacters(matching: query)

        #expect(requestedURL?.query == "name=rick&status=alive&species=Human&type=Genetic%20experiment")
    }

    @Test("Throws unexpectedStatus when the server responds with an error code")
    func throwsOnErrorStatus() async throws {
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                    url: url,
                    statusCode: 404,
                    httpVersion: nil,
                    headerFields: nil
                  ) else {
                throw URLError(.badServerResponse)
            }
            return (response, Data())
        }

        let query = CharacterQuery(name: "rick")
        await #expect(throws: CharacterServiceError.unexpectedStatus(404)) {
            try await makeService().searchCharacters(matching: query)
        }
    }

    @Test("Throws DecodingError when the response body is not valid JSON")
    func throwsOnInvalidJSON() async throws {
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                    url: url,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                  ) else {
                throw URLError(.badServerResponse)
            }
            return (response, Data("not json".utf8))
        }

        let query = CharacterQuery(name: "rick")
        await #expect(throws: DecodingError.self) {
            try await makeService().searchCharacters(matching: query)
        }
    }
}
