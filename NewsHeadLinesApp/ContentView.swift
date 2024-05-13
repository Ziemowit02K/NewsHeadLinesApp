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
    
    let language = ["pl","ar", "ae","at","au", "be","bg", "br","ca","ch","cn","co","cu","cz","de","fr","gb","lt",
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
                                    Text(self.category[$0]).tag($0)
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
        url = "https://newsapi.org/v2/top-headlines?country=\(language[languageChoosen])&category=\(category[categoryChosen])&apiKey=\(ContentView.apiKey)"
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
