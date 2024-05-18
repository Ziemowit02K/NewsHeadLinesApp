//
//  ContentView.swift
//  NewsHeadLinesApp
//
//  Created by Ziemowit Korzeniewski on 12/05/2024.
//


import SwiftUI
import URLImage

struct Result : Codable {
    var articles: [Article]
}
struct Article: Codable {
    var url: String
    var title: String
    var description: String?
    var urlToImage: String?
}
struct ContentView: View {

    @State private var articles = [Article]()
    static let  apiKey = ""
    let category = ["sports","entertainment" , "general" , "health" , "science", "business" , "technology" ]
    @State var categoryChoosen = 0
    
    let language = ["Poland","Argentina", "The United Arab Emirates","Austria","Australia", "Belgium","Bulgaria", "Brazil","Canda","Switzerland","China","Colombia","Cuba","The Czech Republic","Germany","France","Great Britain","Lithuania",
    ]
    @State var languageChoosen = 0
   
    @State var url : String = "https://newsapi.org/v2/top-headlines?country=pl&category=sports&apiKey=\(apiKey)"
    
    
    var body: some View {
        NavigationView {
            
            ZStack
            {
                LinearGradient(colors: [.black,.black], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
                VStack{
                    VStack{
                        Text("News").foregroundColor(.white).font(.system(size: 26, weight: .heavy, design: .monospaced))
                            .underline(pattern:.dash)
                        HStack{
                            
                            Text("Category:").font(.system(size: 19, weight: .medium, design: .monospaced))
                            Picker(selection: $categoryChoosen, label: Text("Category"))
                            {
                                ForEach(0 ..< 6)
                                {
                                    Text(self.category[$0].capitalized).tag($0)
                                }
                            }.onChange(of: categoryChoosen, perform: { tag in
                                url = getAPIurl(category: category, categoryChosen: categoryChoosen, language: language, languageChoosen: languageChoosen)
                                fetchData()
                            })}
                        HStack{
                            Text("Language:").font(.system(size: 19, weight: .medium, design: .monospaced))
                            Picker(selection: $languageChoosen, label: Text("Language"))
                            {
                                ForEach(0 ..< language.count)
                                {
                                    Text(self.language[$0]).tag($0)
                                }
                            }.onChange(of: languageChoosen, perform: { tag in
                                url = getAPIurl(category: category, categoryChosen: categoryChoosen, language: language, languageChoosen: languageChoosen)
                                fetchData()
                            })}
                    }
                .foregroundColor(.white)
                .accentColor(.white)
                List(articles, id: \.url){item in
                    NavigationLink(destination: WidokNewsa(url: item.url)){
                        HStack(alignment: .top){
                            URLImage(( URL(string:item.urlToImage ??
                                           "https://picsum.photos/100")
                                       ?? nil
                            )!){
                                image in image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }.frame(width: 100.0, height: 100.0)
                            
                            
                            VStack(alignment: .leading){
                                Text(item.title)
                                    .font(.headline)
                                Text(item.description ?? "")
                                    .font(.footnote)
                                
                            }
                        }
                    }
                    
                } .onAppear(perform: fetchData)
                    .frame(height: 600)
                
            } .foregroundColor(.white)
                .colorScheme(.dark).ignoresSafeArea()
        }
            }.accentColor(.black)
        }
    
    func getAPIurl( category: [String], categoryChosen: Int, language: [String], languageChoosen: Int) -> String
    {
        var API_language = ""
        switch languageChoosen
        {
        case 0:
            API_language = "pl"
        case 1:
            API_language = "ar"
        case 2:
            API_language = "ae"
        case 3:
            API_language = "at"
        case 4:
            API_language = "au"
        case 5:
            API_language = "be"
        case 6:
            API_language = "bg"
        case 7:
            API_language = "br"
        case 8:
            API_language = "ca"
        case 9:
            API_language = "ch"
        case 10:
            API_language = "cn"
        case 11:
            API_language = "co"
        case 12:
            API_language = "cu"
        case 13:
            API_language = "cz"
        case 14:
            API_language = "de"
        case 15:
            API_language = "de"
        case 16:
            API_language = "fr"
        case 17:
            API_language = "gb"
        case 18:
            API_language = "lt"
        default:
            API_language = "pl"
        }

        url = "https://newsapi.org/v2/top-headlines?country=\(API_language )&category=\(category[categoryChosen])&apiKey=\(ContentView.apiKey)"
        return url
    }
    
    func fetchData(){
        guard let url = URL(string: url) else {
            print("URL nieosiagalne")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request){
            data, response, error in
            if let data = data {
                if let decodedResult = try?
                    JSONDecoder().decode(Result.self, from: data){
                    DispatchQueue.main.async {
                        self.articles = decodedResult.articles
                    }
                    return
                }
            }
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}
#Preview {
    ContentView()
}
