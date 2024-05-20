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
    var status : String = ""
    var totalResults : Int
}
struct Article: Codable {
    var url: String
    var title: String
    var description: String?
    var urlToImage: String?
}

struct ContentView: View {
//Api:
    @State private var articles = [Article]()
    @State private var status : String = ""
    @State private var totalResult : Int = 0
    static let  apiKey = "0cbd932f8c024e4383ec7735e62f355c"
    @State var url : String = "https://newsapi.org/v2/top-headlines?country=pl&category=business&apiKey=\(apiKey)&pageSize=10&page=0"
//Category:
    let category = ["business","sports","entertainment" , "general" , "health" , "science" , "technology" ]
    @State var categoryChoosen = 0
//Language:
    let language = ["Poland","Argentina", "The United Arab Emirates","Austria","Australia", "Belgium","Bulgaria", "Brazil","Canda","Switzerland","China","Colombia","Cuba","The Czech Republic","Germany","France","Great Britain","Lithuania",
    ]
    @State var languageChoosen : Int = 0
//Pages:
    @State var pageNumber : Int = 0
    
//Button:
    @State var nextButtonOppacity : Double = 1.00
    @State var prevButtonOppacity : Double = 0.30
    
    var body: some View {
        NavigationView {
            
            ZStack
            {
                LinearGradient(colors: [.black,.black], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
                VStack{
                    VStack{
                        Spacer()
                            .frame(minHeight: 10, idealHeight: 48, maxHeight: 20)
                            .fixedSize()
                        Divider()
                        Text("News").foregroundColor(.white).font(.system(size: 26, weight: .heavy, design: .monospaced))
                        Divider()
                        Spacer()
                            .frame(minHeight: 10, idealHeight: 18, maxHeight: 20)
                            .fixedSize()
                        ZStack{
                            Color.white
                                .opacity(0.05)
                                .frame(width: 350, height: 100)
                                .cornerRadius(35)
                        VStack{
                            HStack{
                                
                                Text("Category:").font(.system(size: 19, weight: .medium, design: .monospaced))
                                Picker(selection: $categoryChoosen, label: Text("Category"))
                                {
                                    ForEach(0 ..< 6)
                                    {
                                        Text(self.category[$0].capitalized).tag($0)
                                    }
                                }.onChange(of: categoryChoosen, perform: { tag in
                                    url = getAPIurl(category: category, categoryChosen: categoryChoosen, language: language, languageChoosen: languageChoosen, pageNumber: pageNumber)
                                    if check_API_response(totalResults: totalResult, status: status)
                                    {
                                        fetchData()
                                    }
                                    
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
                                    url = getAPIurl(category: category, categoryChosen: categoryChoosen, language: language, languageChoosen: languageChoosen, pageNumber: pageNumber)
                                    if check_API_response(totalResults: totalResult, status: status)
                                    {
                                        fetchData()
                                    }
                        })}
                        }
                    }
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
                    .frame(height: 550)
                    Spacer().frame(minHeight: 10, idealHeight: 20, maxHeight: 22)
                    HStack
                    {
                        
                        Button("\(Image(systemName: "arrow.left")) Previous Side")
                        {
                           
                            
                            if(pageNumber != 0)
                            {
                                prevButtonOppacity=1.0
                                pageNumber -= 1
                                if(check_API_response(totalResults: totalResult, status: status))
                                {
                                    url = getAPIurl(category: category, categoryChosen: categoryChoosen, language: language, languageChoosen: languageChoosen, pageNumber: pageNumber)
                                    fetchData()
                                    prevButtonOppacity = 1.0
                                    nextButtonOppacity = 1.0
                                }
                                else
                                {
                                    prevButtonOppacity = 0.3
                                }
                            }
                        }.opacity(prevButtonOppacity)
                        Spacer().frame(minWidth: 10, idealWidth: 115, maxWidth: 150).fixedSize()
                        Button("Next Page \(Image(systemName: "arrow.right"))")
                        {
                            pageNumber += 1
                            if pageNumber != 0
                            {
                                prevButtonOppacity += 1.0
                            }
                                if check_API_response(totalResults: totalResult, status: status)
                                {
                                    url = getAPIurl(category: category, categoryChosen: categoryChoosen, language: language, languageChoosen: languageChoosen, pageNumber: pageNumber)
                                    fetchData()
                                    nextButtonOppacity = 1.0
                                   
                                }
                                else
                                {
                                    nextButtonOppacity = 0.3
                                    prevButtonOppacity = 1.0
                                }
                        }.opacity(nextButtonOppacity)
                        
                    }.font(.system(size: 14, weight: .medium, design: .monospaced))
                    Spacer()
                
            } .foregroundColor(.white)
                .colorScheme(.dark).ignoresSafeArea()
        }
            }.accentColor(.black)
        }
    func check_API_response(totalResults: Int, status: String) -> Bool
    {
        if (10*pageNumber<=totalResults && status == "ok")
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    
    
    func getAPIurl( category: [String], categoryChosen: Int, language: [String], languageChoosen: Int , pageNumber: Int) -> String
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

        url = "https://newsapi.org/v2/top-headlines?country=\(API_language )&category=\(category[categoryChosen])&apiKey=\(ContentView.apiKey)&pageSize=10&page=\(pageNumber)"
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
                        self.status = decodedResult.status
                        self.totalResult = decodedResult.totalResults
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
