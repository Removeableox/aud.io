//
//  CropImageView.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import SwiftUI

struct CropImageView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    let onCrop: (UIImage) -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var cropSize: CGSize = .zero
    
    // 2:3 aspect ratio (width:height)
    private let cropAspectRatio: CGFloat = 2.0 / 3.0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let cropWidth = min(geometry.size.width - 40, (geometry.size.height - 200) * cropAspectRatio)
                let cropHeight = cropWidth / cropAspectRatio
                let currentCropSize = CGSize(width: cropWidth, height: cropHeight)
                
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    // Full image
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale = min(max(scale * delta, 1.0), 4.0)
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        // Constrain scale to keep crop area filled
                                        let minScale = calculateMinScale(cropSize: currentCropSize, imageSize: image.size, containerSize: geometry.size)
                                        scale = max(scale, minScale)
                                        constrainOffset(cropSize: currentCropSize, containerSize: geometry.size)
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                        // Constrain offset to keep crop area filled
                                        constrainOffset(cropSize: currentCropSize, containerSize: geometry.size)
                                    }
                            )
                        )
                    
                    // Crop overlay
                    CropOverlay(cropSize: currentCropSize)
                        .frame(width: cropWidth, height: cropHeight)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    cropSize = currentCropSize
                    // Initialize scale to fill crop area
                    let minScale = calculateMinScale(cropSize: currentCropSize, imageSize: image.size, containerSize: geometry.size)
                    scale = minScale
                }
                .onChange(of: geometry.size) { _ in
                    let newCropWidth = min(geometry.size.width - 40, (geometry.size.height - 200) * cropAspectRatio)
                    let newCropHeight = newCropWidth / cropAspectRatio
                    cropSize = CGSize(width: newCropWidth, height: newCropHeight)
                }
            }
            .navigationTitle("Crop Cover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        cropImage(cropSize: cropSize)
                        isPresented = false
                    }
                    .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
    
    private func calculateMinScale(cropSize: CGSize, imageSize: CGSize, containerSize: CGSize) -> CGFloat {
        let imageAspectRatio = imageSize.width / imageSize.height
        let cropAspectRatio = cropSize.width / cropSize.height
        
        if imageAspectRatio > cropAspectRatio {
            // Image is wider - scale based on height
            return cropSize.height / (imageSize.height * (containerSize.height / imageSize.height))
        } else {
            // Image is taller - scale based on width
            return cropSize.width / (imageSize.width * (containerSize.width / imageSize.width))
        }
    }
    
    private func constrainOffset(cropSize: CGSize, containerSize: CGSize) {
        let imageDisplaySize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        let maxOffsetX = (imageDisplaySize.width - cropSize.width) / 2
        let maxOffsetY = (imageDisplaySize.height - cropSize.height) / 2
        
        offset.width = min(max(offset.width, -maxOffsetX), maxOffsetX)
        offset.height = min(max(offset.height, -maxOffsetY), maxOffsetY)
        lastOffset = offset
    }
    
    private func cropImage(cropSize: CGSize) {
        // Calculate the crop rect in image coordinates
        let imageSize = image.size
        let imageAspectRatio = imageSize.width / imageSize.height
        let cropAspectRatio = cropSize.width / cropSize.height
        
        var cropRect: CGRect
        
        if imageAspectRatio > cropAspectRatio {
            // Image is wider - crop width
            let scaledHeight = imageSize.height * scale
            let scaledWidth = scaledHeight * cropAspectRatio
            let cropX = (imageSize.width * scale - scaledWidth) / 2 - offset.width
            let cropY = (scaledHeight - cropSize.height) / 2 - offset.height
            cropRect = CGRect(
                x: max(0, cropX / scale),
                y: max(0, cropY / scale),
                width: min(imageSize.width, scaledWidth / scale),
                height: min(imageSize.height, cropSize.height / scale)
            )
        } else {
            // Image is taller - crop height
            let scaledWidth = imageSize.width * scale
            let scaledHeight = scaledWidth / cropAspectRatio
            let cropX = (scaledWidth - cropSize.width) / 2 - offset.width
            let cropY = (imageSize.height * scale - scaledHeight) / 2 - offset.height
            cropRect = CGRect(
                x: max(0, cropX / scale),
                y: max(0, cropY / scale),
                width: min(imageSize.width, cropSize.width / scale),
                height: min(imageSize.height, scaledHeight / scale)
            )
        }
        
        // Ensure crop rect is within image bounds
        cropRect = cropRect.intersection(CGRect(origin: .zero, size: imageSize))
        
        // Crop the image
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return
        }
        
        let croppedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        onCrop(croppedImage)
    }
}

// MARK: - Crop Overlay

struct CropOverlay: View {
    let cropSize: CGSize
    
    var body: some View {
        ZStack {
            // Darkened overlay
            Color.black.opacity(0.5)
            
            // Clear crop area
            Rectangle()
                .frame(width: cropSize.width, height: cropSize.height)
                .blendMode(.destinationOut)
            
            // Crop border
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: cropSize.width, height: cropSize.height)
        }
        .compositingGroup()
    }
}
