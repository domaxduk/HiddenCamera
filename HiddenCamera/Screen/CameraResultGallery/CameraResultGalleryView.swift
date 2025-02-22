//
//  CameraResultGalleryView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import SwiftUI
import SakuraExtension
fileprivate struct Const {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let padding = 20.0
    static let itemSpacing: CGFloat = 8.0
    static let lineSpacing: CGFloat = 20.0
    static let itemWidth = (screenWidth - padding * 2 - itemSpacing * 2) / 3
}

struct CameraResultGalleryView: View {
    @ObservedObject var viewModel: CameraResultGalleryViewModel
    @State var isShowingDeleteDialog: Bool = false
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                
                if viewModel.items.isEmpty {
                    Spacer()
                    Image("ic_gallery_empty")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64)
                    Text("Your gallery is empty. Scan now to ensure your\narea is safe and save video evidence.")
                        .textColor(.app(.light09))
                        .font(Poppins.regular.font(size: 14))
                        .autoResize(numberLines: 2)
                        .padding(.horizontal, 44)
                        .padding(.top, 12)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        viewModel.input.didTapBack.onNext(())
                    }, label: {
                        Text("Scan now")
                            .font(Poppins.semibold.font(size: 16))
                            .textColor(.white)
                            .padding(.horizontal, 71)
                            .padding(.vertical, 16)
                            .background(Color.app(.main))
                            .cornerRadius(36, corners: .allCorners)
                    }).padding(.top, 28)
                    Spacer()
                } else {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: Array(repeating: .init(spacing: Const.itemSpacing), count: 3), spacing: Const.lineSpacing, content: {
                            ForEach(viewModel.items, id: \.id) { item in
                                CameraResultItemView(viewModel: viewModel, item: item)
                            }
                        })
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)
                    }
                }
            }
            
            if !viewModel.selectedItems.isEmpty {
                VStack {
                    Spacer()
                    
                    Text("Remove")
                        .textColor(.white)
                        .font(Poppins.semibold.font(size: 16))
                        .frame(width: 264, height: 56)
                        .background(AppColor.warningColor)
                        .cornerRadius(56 / 2, corners: .allCorners)
                        .onTapGesture {
                            withAnimation {
                                isShowingDeleteDialog = true
                            }
                        }
                }
            }
            
            if isShowingDeleteDialog {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    
                    VStack {
                        Text("Are you sure want to delete?\nThis action canot be undone")
                            .textColor(.app(.light12))
                            .font(Poppins.semibold.font(size: 16))
                            .scaledToFit()
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                            .padding(.bottom, 30)
                            .padding(.top, 32)
                        
                        Color.app(.light04).frame(height: 1)
                        
                        HStack {
                            Spacer()
                            Text("Remove")
                                .font(Poppins.regular.font(size: 16))
                                .textColor(AppColor.warningColor)
                            Spacer()
                        }
                        .background(Color.clearInteractive)
                        .frame(height: 56)
                        .onTapGesture {
                            withAnimation {
                                viewModel.input.didTapDelete.onNext(())
                                isShowingDeleteDialog = false
                            }
                        }
                        
                        Color.app(.light04).frame(height: 1)

                        HStack {
                            Spacer()
                            Text("Cancel")
                                .font(Poppins.regular.font(size: 16))
                                .textColor(.app(.light12))
                            Spacer()
                        }
                        .background(Color.clearInteractive)
                        .frame(height: 56)
                        .onTapGesture {
                            withAnimation {
                                isShowingDeleteDialog = false
                            }
                        }
                    }
                    .overlay(
                        ZStack(alignment: .topTrailing) {
                            Image("ic_close")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                                .padding(16)
                            
                            Color.clear
                        }
                    )
                    .background(Color.white)
                    .cornerRadius(20, corners: .allCorners)
                    .padding(.horizontal, 20)
                }
            }
        }.frame(width: UIScreen.main.bounds.width)
    }
    
    var navigationBar: some View {
        HStack(spacing: 0) {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(20)
                .background(Color.clearInteractive)
                .onTapGesture {
                    viewModel.input.didTapBack.onNext(())
                }
            
            Text(viewModel.title())
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
                .autoResize(numberLines: 1)
            
            Spacer(minLength: 0)
            
            if !viewModel.items.isEmpty {
                Button(action: {
                    viewModel.input.didTapChangeMode.onNext(())
                }, label: {
                    Text(viewModel.isEditing ? "Cancel" : "Select")
                        .font(Poppins.semibold.font(size: 16))
                        .textColor(.app(.main))
                })
            }
        }
        .padding(.trailing, 20)
        .frame(height: AppConfig.navigationBarHeight)
    }
}

// MARK: - Result Item
fileprivate struct CameraResultItemView: View {
    @ObservedObject var viewModel: CameraResultGalleryViewModel

    var item: CameraResultItem
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
            
            VideoThumbnailImage(loader: ImageLoader(url: item.url))
            
            if tag != nil && !viewModel.isEditing {
                Circle().fill(.white)
                    .frame(width: 24)
                    .overlay(
                        Image(systemName: isRisk ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16)
                            .foreColor(isRisk ? AppColor.warningColor : AppColor.safeColor)
                    )
                    .padding(8)
            }
            
            if viewModel.isEditing {
                ZStack {
                    Circle().stroke(Color.white, lineWidth: 2)
                    
                    if selected {
                        Color.white
                        
                        Image("ic_tick")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 8)
                            .foreColor(.app(.main))
                    }
                }
                .frame(width: 24, height: 24)
                .cornerRadius(12, corners: .allCorners)
                .padding(8)
            }
        }
        .frame(width: Const.itemWidth, height: Const.itemWidth)
        .cornerRadius(16, corners: .allCorners)
        .onTapGesture {
            viewModel.input.didTapItem.onNext(item)
        }
    }
    
    var isRisk: Bool {
        return tag == .risk
    }
    
    var tag: CameraResultTag? {
        return item.tag
    }
    
    var selected: Bool {
        return viewModel.isSelectedItem(id: item.id)
    }
}

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    
    init(url: URL) {
        self.url = url
        self.load()
    }
    
    func load() {
        // Check the cache first
        if let cachedImage = ImageCache.shared.object(forKey: url as NSURL) {
            // If image is found in cache, set it directly
            self.image = cachedImage
            return
        }
        
        // If not cached, fetch from the URL
        DispatchQueue.global().async {
            if let image = self.url.getThumbnailImage()?.resizeToFit(maxSize: Const.itemWidth * 2) {
                // Cache the image once loaded
                ImageCache.shared.setObject(image, forKey: self.url as NSURL)
                
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

// VideoThumbnailImage with the loader as a view
fileprivate struct VideoThumbnailImage: View {
    @ObservedObject var loader: ImageLoader
    
    @ViewBuilder
    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Const.itemWidth, height: Const.itemWidth)
            }
        }
    }
}


// MARK: - Extension
extension CameraResultItem {
    var url: URL {
        return FileManager.documentURL().appendingPathComponent(fileName)
    }
    
    var thumbnailImage: UIImage? {
        return url.getThumbnailImage()
    }
}

#Preview {
    CameraResultGalleryView(viewModel: CameraResultGalleryViewModel(type: .infrared))
}
