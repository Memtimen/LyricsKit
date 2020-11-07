//
//  Kugou.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore
import CXShim
import CXExtensions

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let kugouSearchBaseURLString = "http://lyrics.kugou.com/search"
private let kugouLyricsBaseURLString = "http://lyrics.kugou.com/download"

extension LyricsProviders {
    public final class Kugou {
        public init() {}
    }
}

extension LyricsProviders.Kugou: _LyricsProvider {
    
    public static let service: LyricsProviders.Service = .kugou
    
    func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<KugouResponseSearchResult.Item, Never> {
        let parameter: [String: Any] = [
            "keyword": request.searchTerm.description,
            "duration": Int(request.duration * 1000),
            "client": "pc",
            "ver": 1,
            "man": "yes",
            ]
        let url = URL(string: kugouSearchBaseURLString + "?" + parameter.stringFromHttpParameters)!
        return sharedURLSession.cx.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: KugouResponseSearchResult.self, decoder: JSONDecoder().cx)
            .map(\.candidates)
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .eraseToAnyPublisher()
    }
    
    func lyricsFetchPublisher(token: KugouResponseSearchResult.Item) -> AnyPublisher<Lyrics, Never> {
        let parameter: [String: Any] = [
            "id": token.id,
            "accesskey": token.accesskey,
            "fmt": "krc",
            "charset": "utf8",
            "client": "pc",
            "ver": 1,
        ]
        let url = URL(string: kugouLyricsBaseURLString + "?" + parameter.stringFromHttpParameters)!
        return sharedURLSession.cx.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: KugouResponseSingleLyrics.self, decoder: JSONDecoder().cx)
            .compactMap {
                guard let lrcContent = decryptKugouKrc($0.content),
                    let lrc = Lyrics(kugouKrcContent: lrcContent) else {
                        return nil
                }
                lrc.idTags[.title] = token.song
                lrc.idTags[.artist] = token.singer
                lrc.idTags[.lrcBy] = "Kugou"
                
                lrc.length = Double(token.duration)/1000
                lrc.metadata.service = Self.service
                lrc.metadata.serviceToken = "\(token.id),\(token.accesskey)"
                return lrc
            }.ignoreError()
            .eraseToAnyPublisher()
    }
}
