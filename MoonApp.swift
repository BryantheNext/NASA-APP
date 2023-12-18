//
//  MoonApp.swift
//  ParseCSV
//
//  Created by Leos, Bryan - Student on 11/14/23.
//

//Fix the the draw path, app storage to fix the lastdraw, finger zooming out of the map, make the clear all delete all zoom and other viewing effects, and fix the tower from moving when zooming

import SwiftUI

enum Mode { case addTowerPoint,addPath, dragPoint, selDelete, screenScroll
    
    var tower: Bool {
        switch self {
        case .addTowerPoint:
            return true
        case .addPath:
            return false
        case .dragPoint:
            return false
        case .selDelete:
            return false
        case .screenScroll:
            return false
        }
    }
    var path: Bool {
        switch self {
        case .addTowerPoint:
            return false
        case .addPath:
            return true
        case .dragPoint:
            return false
        case .selDelete:
            return false
        case .screenScroll:
            return false
        }
    }
    var drag:Bool {
        switch self {
        case .addTowerPoint:
            return false
        case .addPath:
            return false
        case .dragPoint:
            return true
        case .selDelete:
            return false
        case .screenScroll:
            return false
        }
    }
    var delete:Bool {
        switch self {
        case .addTowerPoint:
            return false
        case .addPath:
            return false
        case .dragPoint:
            return false
        case .selDelete:
            return true
        case .screenScroll:
            return false
        }
    }
    var scrollScreen:Bool {
        switch self {
        case .addTowerPoint:
            return false
        case .addPath:
            return false
        case .dragPoint:
            return false
        case .selDelete:
            return false
        case .screenScroll:
            return true
        }
    }

}

enum MapType { case slope, height
    
    var mapTitle: String {
        switch self {
        case .slope:
            return "Slope Map:"
        case .height:
            return "Height Map:"
        }
    }
    var mapName: String {
        switch self {
        case .slope:
            return "moonImage"
        case .height:
            return "moonImageHet"
        }
    }
        
    var color1: Color {
        switch self {
        case .slope:
            return .red
        case .height:
            return .black
        }
    }
    var color2: Color {
        switch self {
        case .slope:
            return .green
        case .height:
            return .purple
        }
    }
    var color3: Color {
        switch self {
        case .slope:
            return .blue
        case .height:
            return .yellow
        }
    }
    var measurements1: String {
        switch self {
        case .slope:
            return "15 & 15+ degrees"
        case .height:
            return "1200-1200+ meters"
        }
    }
    var measurements2: String {
        switch self {
        case .slope:
            return "6-14 degrees"
        case .height:
            return "900-1199 meters"
        }
    }
    var measurements3: String {
        switch self {
        case .slope:
            return "<5 degrees"
        case .height:
            return "<900 meters"
        }
    }
}

struct MoonApp: View {
    @AppStorage("line") var line: [CGPoint] = [.zero, CGPoint(x:100, y:100), CGPoint(x:200, y:0)]
    @AppStorage("towers") var towers: [CGPoint] = [ CGPoint(x:100, y:100)]
    @State var selDelete = false
    
    @State var selectedIndex: Int?
    @State var scale: CGFloat = 1.0
    @State var isTapped: Bool = false
    @State var pointTapped: CGPoint = CGPoint.zero
    @State var draggedSize: CGSize = CGSize.zero
    @State var previousDragged: CGSize = CGSize.zero
    @State var mode: Mode = .addPath
    @State var viewSize:CGSize = .zero
    @State var heightMapAppear = false
    @State var scollCondition = false
    
    
    @State var mapName = "moonImage"
    @State var mapType = MapType.slope
   // @State var mode = Mode.
   @State private var scrollViewContentSize: CGSize = .zero

    
    @State private var orientation = UIDeviceOrientation.unknown
    // @Environment var globalStates: GlobalStates
    var body: some View {
        // Group{
        //  if globalStates.isLandScape{
        let rendererSelected = ImageRenderer(content: Image("towerCorrect").resizable().frame(width: 35, height: 35)
            .padding(4)
            .border(.white, width: 3)
        )  //foregroundColor(.white))
        let renderer = ImageRenderer(content: Image("towerCorrect").resizable().frame(width: 35, height: 35)
        )  //foregroundColor(.white))
        let antenna = Image(uiImage: renderer.uiImage!)
        let antennaSel = Image(uiImage: rendererSelected.uiImage!)
        
        GeometryReader{ reader in
            VStack {
                // withAnimation(.default){
                Text(mapType.mapTitle)
                    .font(.largeTitle)
                ScrollView([.horizontal, .vertical]) {
                    
                    //Map Changes with a button.
                    Image(mapType.mapName)
                    // Image(map[0] as! ImageResource)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(x: self.draggedSize.width, y: 0)
                        .scaleEffect(self.scale,
                                     anchor: UnitPoint(
                                        x: self.pointTapped.x / reader.frame(in: .global).maxX,
                                        y: self.pointTapped.y / reader.frame(in: .global).maxY
                                        
                                     ))
                    
                        .overlay{
                            Canvas {context, size in
                                var path = Path()
                                path.addLines(line)
                                context.stroke(path, with: .color(.indigo), lineWidth: 5)
                                for (index, tower) in towers.enumerated() {
                                    if let selected = selectedIndex {
                                        if selected == index{
                                            context.draw(antennaSel, at: tower)
                                        } else {
                                            context.draw(antenna, at: tower)
                                        }
                                    } else {
                                        context.draw(antenna, at: tower)
                                    }
                                }
                            }
                            //  .saveSize(in: $viewSize)
                            
                            .onTapGesture{ location in
                                var distances: [CGFloat] = []
                                for tower in towers {
                                    let dist = distance(p1: location, p2: tower)
                                    distances.append(dist)
                                }
                                var minIndex = 0
                                var minDistance: CGFloat = 100000
                                for (index, dist) in distances.enumerated() {
                                    if dist < minDistance {
                                        minDistance = dist
                                        minIndex = index
                                    }
                                }
                                if minDistance < 35 {
                                    selectedIndex = minIndex
                                } else {
                                    towers.append(location)
                                }
                            }
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged({ value in
                                    switch mode {
                                    case .addTowerPoint:
                                        break
                                    case .addPath:
                                        // let _ = line.dropLast()
                                        line.append(value.location)
                                    case .dragPoint:
                                        for (index, _) in towers.enumerated(){
                                            if let selected = selectedIndex {
                                                if selected == index{
                                                    towers[selected] = value.location
                                                    
                                                }
                                            }
                                        }
                                    case .selDelete:
                                        break
                                    case .screenScroll:
                                        break
                                    }
                                }
                                          )
                            )
                            
                            .gesture(MagnificationGesture()
                                .onChanged({ (scale) in
                                   // self.scale = scale.magnitude
                                    self.scale = min(max(scale.magnitude, 0.1), 2.0)
                                }).onEnded({ (scaleFinal) in
                                    //self.scale = scaleFinal.magnitude
                                    self.scale = min(max(scaleFinal.magnitude, 0.1), 2.0)
                                    print(scale)
                                }))
                        }}
                
                
                .background(
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            scrollViewContentSize = geo.size
                        }
                            return Color.clear
                    }
                )
            .frame(
                minWidth: scrollViewContentSize.width
            )
                 
        
                    .scrollDisabled(scollCondition)// ,
                    //Change this when you change maps.
                   // idealWidth: HStack{
                HStack{
                    HStack{
                        VStack{
                            Rectangle()
                                .frame(width: 30,height: 15)
                                .foregroundStyle(mapType.color1)
                            // .foregroundStyle(Color.map[1])
                            Rectangle()
                                .frame(width:30,height:15)
                                .foregroundStyle(mapType.color2)
                            Rectangle()
                                .frame(width:30,height:15)
                                .foregroundStyle(mapType.color3)
                        }
                        VStack{
                            Text(mapType.measurements1)
                            Text(mapType.measurements2)
                            Text(mapType.measurements3)
                        }
                    }
                    .border(Color.black)
                    Button{
                        if mapType == .height {
                            mapType = .slope
                        } else {
                            mapType = .height
                        }
                    }label:{
                        Text("Change Map")
                            .font(.title)
                            .foregroundStyle(Color.white)
                            .background(Color.black)
                            .frame(width:200,height:75)
                    }
                    Button{
                        line = []
                        towers = []
                        scale = 1
                    }label: {
                        Text("Clear All").padding().font(.title)
                    }
                }
                HStack{
                    HStack{
                        HStack{
                            Button{
                                if scale == 1.0 {
                                    scale += 0.5
                                } else if scale == 1.5{
                                    scale += 0.5
                                } else if scale == 2.0{
                                    scale += 0.5
                                }else if scale == 2.5{
                                    scale += 0.5
                                }
                            }label:{
                                Image("zoomIn")
                                    .resizable()
                                    .frame(width:40,height:40)
                            }
                            Divider()
                                .frame(width:10,height:40)
                            Button{
                                if scale == 3.0{
                                    scale -= 0.5
                                } else if scale == 2.5{
                                    scale -= 0.5
                                } else if scale == 2.0{
                                    scale -= 0.5
                                } else if scale == 1.5{
                                    scale -= 0.5
                                }
                            }label:{
                                Image("zoomOut")
                                    .resizable()
                                    .frame(width:40,height:40)
                            }
                            Divider()
                                .frame(width:10,height:40)
                            Button{
                                mode = .screenScroll
                                scollCondition = false
                                
                            }label:{
                                Image("screenScroll")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                
                            }
                        }
                        .frame(width: 200, height: 45)
                        .overlay(Rectangle().stroke(Color.gray, lineWidth: 2))
                        .frame(width: 160)
                    }
                    .padding(50)
                   
                    HStack{
                        Button{
                            mode = .addTowerPoint
                            scollCondition = false

                        }label:{
                            Image("towerCorrect")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        Divider()
                            .frame(width:10,height:40)
                        Button{
                            mode = .selDelete
                            scollCondition = false
                                for (index, _) in towers.enumerated(){
                                    if let selected = selectedIndex {
                                        if selected == index{
                                            towers.remove(at: selected)
                                        }
                                        
                                    }
                                }
                                for (index, _) in towers.enumerated(){
                                    if let selected = selectedIndex {
                                        if selected == index{
                                            line.remove(at: selected)
                                        }
                                        
                                    }
                                }
                                selDelete.toggle()
                            // }
                            
                        }label:{
                            Image("trashCan")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        Divider()
                            .frame(width:10,height:40)
                        Button{
//
                            mode = .addPath
                            scollCondition = false
//
                        }label:{
                            Image("draw")
                                .resizable()
                                .frame(width: 40, height: 40)
                            
                        }
                        Divider()
                            .frame(width:10,height:40)
                        Button{
                            mode = .dragPoint
                            scollCondition = true
                            
                        }label:{
                            Image("pointDrag")
                                .resizable()
                                .frame(width: 40, height: 40)
                            
                        }
                    }
                    .frame(width: 300, height: 45)
                    .overlay(Rectangle().stroke(Color.gray, lineWidth: 2))
                    .frame(width: 200)
                    
                }
            }
    }
}
    
    
            
            
            func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
                let dx = p2.x - p1.x
                let dy = p2.y - p1.y
                let c = ((dx * dx) + (dy * dy)).squareRoot()
                return c
            }
        }

#Preview {
    MoonApp()
}
  
