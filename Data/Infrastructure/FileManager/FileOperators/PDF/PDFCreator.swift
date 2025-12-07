//
//  PDFCreator.swift
//  EarnLog
//
//  Created by M3 pro on 28/08/2025.
//
import Foundation
import PDFKit

// MARK: - Генератор PDF с правильной обработкой переполнения страниц
class PDFCreator: FileDataCreator {

    private let margin: CGFloat = 40
    private let footerHeight: CGFloat = 50
    
    func createData(context: DataProcessingContext) throws -> Data {
       createPDFData(context: context)
    }
    
//    func create(context: DataProcessingContext, 
//                folders: (mainLocation: StorageLocation, backupLocation: StorageLocation)) 
//    -> Result<StorageLocation, FileHandlerError> {
//        
//        let fileName = "\(context.fileName).pdf"
//        let mainLocation = folders.mainLocation.with(fileName: fileName)
//        let backupLocation = folders.backupLocation.with(fileName: fileName)
//        
//        do {
//            let pdfData = try createPDFData(context: context)
//            return fileStorageService.write(pdfData, to: folders)
//        } catch {
//            return .failure(.fileCreationFailed)
//        }
//    }
}

extension PDFCreator {
    // MARK: - Главный метод создания PDF 
    private func createPDFData(context: DataProcessingContext) -> Data {
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(origin: .zero, size: 
                                                            context.configuration.pageSize), nil)
        
        let headers = ["№"] + (context.columnHeaders)
        let itemsPerPage = context.configuration.maxRowsPerPage
        let totalPages = (context.items.count + itemsPerPage - 1) / itemsPerPage
        
        // Сначала проверяем, поместится ли summary на последней странице
        var actualPageCount = totalPages
        var needsExtraSummaryPage = false
        
        if context.configuration.includeTotal {
            let lastPageStartIndex = (totalPages - 1) * itemsPerPage
            let lastPageEndIndex = min(lastPageStartIndex + itemsPerPage, context.items.count)
            let lastPageItems = Array(context.items[lastPageStartIndex..<lastPageEndIndex])
            
            if !willSummaryFitOnPage(context: context, with: lastPageItems.count, headers: headers) {
                actualPageCount += 1
                needsExtraSummaryPage = true
            }
        }
        
        // Создаем страницы с данными
        for pageIndex in 0..<totalPages {
            let startIndex = pageIndex * itemsPerPage
            let endIndex = min(startIndex + itemsPerPage, context.items.count)
            let pageItems = Array(context.items[startIndex..<endIndex])
            
            UIGraphicsBeginPDFPage()
            
            let isLastPage = (pageIndex == totalPages - 1)
            let shouldIncludeSummaryOnThisPage = isLastPage && context.configuration.includeTotal && !needsExtraSummaryPage
            
            _ = drawPage(
                context: context,
                items: pageItems,
                headers: headers,
                pageNumber: pageIndex + 1,
                totalPages: actualPageCount,
                startRowNumber: startIndex + 1,
                includeSummary: shouldIncludeSummaryOnThisPage
            )
        }
        
        // Если нужна отдельная страница для итогов
        if needsExtraSummaryPage {
            UIGraphicsBeginPDFPage()
            drawSummaryPage(context: context,pageNumber: actualPageCount, totalPages: actualPageCount)
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
//    // MARK: - Public methods
//    private func processToPDF(context: DataProcessingContext,
//                                 folders: (mainPath: StorageLocation, backupPath: StorageLocation)) 
//       -> Result<StorageLocation, FileHandlerError> {
//           
//           let fileName = "\(context.fileName).pdf"
//           
//           // Получаем пути в зависимости от типа хранилища
//           guard let mainURL = folders.mainPath.fileURL(appendingComponent: fileName),
//                 let backupURL = folders.backupPath.fileURL(appendingComponent: fileName) else {
//               return .failure(.invalidPath)
//           }
//           
//           do {
//               let pdfData = try createPDFData(context: context)
//               return writeFile(content: pdfData, 
//                              mainLocation: folders.mainPath.with(fileName: fileName),
//                              backupLocation: folders.backupPath.with(fileName: fileName))
//           } catch {
//               return .failure(.fileCreationFailed)
//           }
//       }
//       
//       private func writeFile(content: Data, 
//                             mainLocation: StorageLocation, 
//                             backupLocation: StorageLocation) 
//       -> Result<StorageLocation, FileHandlerError> {
//           
//           // Обработка в зависимости от типа хранилища
//           switch (mainLocation, backupLocation) {
//           case (.local(let mainPath), .local(let backupPath)):
//               return writeLocalFile(content: content, mainPath: mainPath, backupPath: backupPath)
//               
//           case (.cloud(let mainURL), .cloud(let backupURL)):
//               return writeCloudFile(content: content, mainURL: mainURL, backupURL: backupURL)
//               
//           default:
//               return .failure(.incompatibleStorageTypes)
//           }
//       }
//       
//       // MARK: - Local Storage
//       private func writeLocalFile(content: Data, mainPath: String, backupPath: String) 
//       -> Result<StorageLocation, FileHandlerError> {
//           do {
//               let mainURL = URL(filePath: mainPath)
//               let backupURL = URL(filePath: backupPath)
//               
//               // Удаляем существующие файлы
//               [mainURL, backupURL].forEach { url in
//                   if fileStorageService.exists(at: url) {
//                       try? fileStorageService.removeItem(at: url)
//                   }
//               }
//               
//               // Записываем файлы
//               try content.write(to: mainURL)
//               try fileManager.copyItem(at: mainURL, to: backupURL)
//               
//               return .success(.local(path: mainURL.path))
//           } catch {
//               print("❌ Ошибка при записи локального файла: \(error)")
//               return .failure(.fileCreationFailed)
//           }
//       }
//       
//       // MARK: - Cloud Storage
//       private func writeCloudFile(content: Data, mainURL: URL, backupURL: URL) 
//       -> Result<StorageLocation, FileHandlerError> {
//           // TODO: Реализация загрузки в облако
//           // Например, через URLSession или CloudKit
//           return .failure(.cloudUploadNotImplemented)
//       }
    
   
    
    // MARK: - Обновленный метод рисования страницы
//    @discardableResult
    private func drawPage(
        context: DataProcessingContext, 
        items: [IncomeEntry], 
        headers: [String], 
        pageNumber: Int, 
        totalPages: Int, 
        startRowNumber: Int, 
        includeSummary: Bool = false
    ) -> Bool {
        var yPosition: CGFloat = margin
        
        // Рисуем брендинг приложения
        yPosition = drawAppBranding(context: context, at: yPosition)
        yPosition += 30
        
        // Рисуем заголовок документа
        yPosition = drawTitle(context: context, at: yPosition)
        yPosition += 20
        
        // Рисуем заголовки колонок
        yPosition = drawHeaders(headers, context: context, at: yPosition)
        yPosition += 10
        
        // Рисуем строки данных с нумерацией
        for (index, item) in items.enumerated() {
            let rowNumber = String(startRowNumber + index)
            let rowData = [rowNumber] + context.stringsForRow(item: item)
            yPosition = drawDataRow(context: context, rowData: rowData, at: yPosition)
            yPosition += 5
        }
        
        // Если нужно включить итоги на этой странице
        if includeSummary {
            yPosition += 20
            _ = drawSummaryOnSamePage(context: context, at: yPosition)
        }
        
        // Рисуем подвал с номером страницы
        drawFooter(context: context, pageNumber: pageNumber, totalPages: totalPages)
        
        return true // Всегда успешно, так как проверка выполняется заранее
    }
    
    // MARK: - Отдельная страница для итогов
    private func drawSummaryPage(context: DataProcessingContext, pageNumber: Int, totalPages: Int) {
        var yPosition: CGFloat = margin
        
        // Рисуем брендинг приложения
        yPosition = drawAppBranding(context: context, at: yPosition)
        yPosition += 30
        
        let pageSize = context.configuration.pageSize
        
        // Заголовок страницы итогов
        let summaryPageTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: context.configuration.primaryColor
        ]
        
        let summaryPageTitle = "Итоговые данные"
        let titleSize = summaryPageTitle.size(withAttributes: summaryPageTitleAttributes)
        let centerX = pageSize.width / 2
        let titleRect = CGRect(
            x: centerX - titleSize.width / 2,
            y: yPosition,
            width: titleSize.width,
            height: titleSize.height
        )
        
        summaryPageTitle.draw(in: titleRect, withAttributes: summaryPageTitleAttributes)
        yPosition += titleSize.height + 40
        
        // Рисуем итоги
        _ = drawSummaryOnSamePage(context: context, at: yPosition)
        
        // Рисуем подвал
        drawFooter(context: context, pageNumber: pageNumber, totalPages: totalPages)
    }
    
    // MARK: - Расчет высоты секции итогов
    private func calculateSummaryHeight() -> CGFloat {
        let baseHeight: CGFloat = 15 + 25 + 15 // Разделительная линия + заголовок + отступ
        let rowHeight: CGFloat = 18
        let numberOfSummaryRows = 4 // Количество, общий объем, рассчитанные, нерассчитанные
        
        return baseHeight + (rowHeight * CGFloat(numberOfSummaryRows))
    }
    
    // MARK: - Проверка поместится ли summary на странице с данными
    private func willSummaryFitOnPage(context: DataProcessingContext, with itemsCount: Int, headers: [String]) -> Bool {
        let headerHeight: CGFloat = 40 + 30 + 20 + 25 + 10 // Брендинг + заголовок + заголовки колонок
        let dataRowHeight: CGFloat = 23 // 18 + 5 отступ
        let summaryHeight = calculateSummaryHeight()
        let summaryPadding: CGFloat = 20 // Отступ перед итогами
        
        let totalContentHeight = headerHeight + 
                                (CGFloat(itemsCount) * dataRowHeight) + 
                                summaryPadding + 
                                summaryHeight
        let pageSize = context.configuration.pageSize
        
        let availableHeight = pageSize.height - (2 * margin) - footerHeight
        
        return totalContentHeight <= availableHeight
    }
    
    // MARK: - Метод для рисования итогов на той же странице (без изменений)
    private func drawSummaryOnSamePage(context: DataProcessingContext, at yPosition: CGFloat) -> CGFloat {
        let summary = context.summary
        var currentY = yPosition
        let pageSize = context.configuration.pageSize
        
        // Рисуем разделительную линию
        let lineStart = CGPoint(x: margin, y: currentY)
        let lineEnd = CGPoint(x: pageSize.width - margin, y: currentY)
        
        let linePath = UIBezierPath()
        linePath.move(to: lineStart)
        linePath.addLine(to: lineEnd)
        context.configuration.primaryColor.setStroke()
        linePath.lineWidth = 1
        linePath.stroke()
        
        currentY += 15
        
        // Заголовок итогов
        let summaryTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: context.configuration.primaryColor
        ]
        
        let summaryTitle = "Итоги:"
        let summaryTitleRect = CGRect(x: margin, y: currentY, width: 200, height: 20)
        summaryTitle.draw(in: summaryTitleRect, withAttributes: summaryTitleAttributes)
        currentY += 25
        
        // Настройки для текста итогов
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: context.configuration.primaryColor
        ]
        
        let leftMargin = margin + 20
        let rightMargin = pageSize.width - margin - 20
        let rowHeight: CGFloat = 18
        
        // Общее количество
        currentY = drawSummaryRowCompact(
            label: "Общее количество:",
            value: String(summary.totalCount),
            at: currentY,
            leftMargin: leftMargin,
            rightMargin: rightMargin,
            labelAttributes: labelAttributes,
            valueAttributes: valueAttributes
        )
        currentY += rowHeight
        
        // Общий объем
        currentY = drawSummaryRowCompact(
            label: "Общий объем:",
            value: String(format: "%.2f", summary.totalVolume),
            at: currentY,
            leftMargin: leftMargin,
            rightMargin: rightMargin,
            labelAttributes: labelAttributes,
            valueAttributes: valueAttributes
        )
        currentY += rowHeight
        
        // Объем рассчитанных
        currentY = drawSummaryRowCompact(
            label: "Объем рассчитанных:",
            value: String(format: "%.2f", summary.paidVolume),
            at: currentY,
            leftMargin: leftMargin,
            rightMargin: rightMargin,
            labelAttributes: labelAttributes,
            valueAttributes: valueAttributes
        )
        currentY += rowHeight
        
        // Объем не рассчитанных
        currentY = drawSummaryRowCompact(
            label: "Объем не рассчитанных:",
            value: String(format: "%.2f", summary.unpaidVolume),
            at: currentY,
            leftMargin: leftMargin,
            rightMargin: rightMargin,
            labelAttributes: labelAttributes,
            valueAttributes: valueAttributes
        )
        
        return currentY + rowHeight
    }
    
    // MARK: - Остальные методы остаются без изменений
    private func drawSummaryRowCompact(
        label: String, 
        value: String, 
        at yPosition: CGFloat,
        leftMargin: CGFloat, 
        rightMargin: CGFloat,
        labelAttributes: [NSAttributedString.Key: Any],
        valueAttributes: [NSAttributedString.Key: Any]
    ) -> CGFloat {
        
        // Рисуем метку слева
        let labelRect = CGRect(x: leftMargin, y: yPosition, width: 200, height: 15)
        label.draw(in: labelRect, withAttributes: labelAttributes)
        
        // Рисуем значение справа
        let valueSize = value.size(withAttributes: valueAttributes)
        let valueRect = CGRect(
            x: rightMargin - valueSize.width,
            y: yPosition,
            width: valueSize.width,
            height: 15
        )
        value.draw(in: valueRect, withAttributes: valueAttributes)
        
        return yPosition
    }
    
    private func drawAppBranding(context: DataProcessingContext, at yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let pageSize = context.configuration.pageSize
        let centerX = pageSize.width / 2
        
        // Размеры элементов
        let logoSize: CGFloat = 40
        let spacing: CGFloat = 2
        
        // Название приложения
        let appNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: context.configuration.primaryColor
        ]
        
        let appNameSize = context.configuration.appName.size(withAttributes: appNameAttributes)
        
        // Общая ширина: логотип + отступ + текст
        let totalWidth = logoSize + spacing + appNameSize.width
        
        // Начальная точка по X (центрируем всю группу)
        let startX = centerX - totalWidth / 2
        
        // Рисуем логотип (если есть)
        if let logo = context.configuration.appLogo {
            let logoRect = CGRect(x: startX, y: currentY, width: logoSize, height: logoSize)
            logo.draw(in: logoRect)
        }
        
        // Рисуем название справа от логотипа
        let appNameRect = CGRect(
            x: startX + logoSize + spacing,
            y: currentY + logoSize / 2,
            width: appNameSize.width,
            height: appNameSize.height
        )
        context.configuration.appName.draw(in: appNameRect, withAttributes: appNameAttributes)
        
        // Сдвигаем Y на высоту логотипа + отступ
        currentY += logoSize + 15
        
        // Рисуем разделительную линию
        let lineY = currentY
        let lineStart = CGPoint(x: margin, y: lineY)
        let lineEnd = CGPoint(x: pageSize.width - margin, y: lineY)
        
        let linePath = UIBezierPath()
        linePath.move(to: lineStart)
        linePath.addLine(to: lineEnd)
        context.configuration.secondaryColor.setStroke()
        linePath.lineWidth = 1
        linePath.stroke()
        
        return currentY + 15
    }
    
    // Рисование заголовка документа
    private func drawTitle(context: DataProcessingContext, at yPosition: CGFloat) -> CGFloat {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: context.configuration.primaryColor
        ]
        let pageSize = context.configuration.pageSize
        let titleSize = context.displayTitle.size(withAttributes: titleAttributes)
        let centerX = pageSize.width / 2
        let titleRect = CGRect(
            x: centerX - titleSize.width / 2,
            y: yPosition,
            width: titleSize.width,
            height: titleSize.height
        )
        
        context.displayTitle.draw(in: titleRect, withAttributes: titleAttributes)
        
        return yPosition + titleSize.height
    }
    
    // Рисование заголовков колонок
    private func drawHeaders(_ headers: [String], context: DataProcessingContext,  
                             at yPosition: CGFloat) -> CGFloat {
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.white
        ]
        let pageSize = context.configuration.pageSize
        let columnWidth = (pageSize.width - 2 * margin) / CGFloat(headers.count)
        let headerHeight: CGFloat = 25
        
        let headerBackgroundRect = CGRect(
            x: margin,
            y: yPosition,
            width: pageSize.width - 2 * margin,
            height: headerHeight
        )
        
        context.configuration.primaryColor.setFill()
        UIBezierPath(rect: headerBackgroundRect).fill()
        
        for (index, header) in headers.enumerated() {
            let x = margin + CGFloat(index) * columnWidth
            let rect = CGRect(x: x + 5, y: yPosition + 5, width: columnWidth - 10, height: 15)
            header.draw(in: rect, withAttributes: headerAttributes)
        }
        
        return yPosition + headerHeight + 5
    }
    
    // Рисование строки данных
    private func drawDataRow(context: DataProcessingContext, rowData: [String], at yPosition: CGFloat) -> CGFloat {
        let dataAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        let pageSize = context.configuration.pageSize
        let columnWidth = (pageSize.width - 2 * margin) / CGFloat(rowData.count)
        
        for (index, data) in rowData.enumerated() {
            let x = margin + CGFloat(index) * columnWidth
            let rect = CGRect(x: x + 5, y: yPosition, width: columnWidth - 10, height: 15)
            data.draw(in: rect, withAttributes: dataAttributes)
        }
        
        return yPosition + 18
    }
    
    // Рисование подвала страницы
    private func drawFooter(context: DataProcessingContext, pageNumber: Int, totalPages: Int) {
        let pageSize = context.configuration.pageSize
        let footerY = pageSize.height - margin - 30
        
        let lineY = footerY - 10
        let lineStart = CGPoint(x: margin, y: lineY)
        let lineEnd = CGPoint(x: pageSize.width - margin, y: lineY)
        
        let linePath = UIBezierPath()
        linePath.move(to: lineStart)
        linePath.addLine(to: lineEnd)
        context.configuration.secondaryColor.setStroke()
        linePath.lineWidth = 0.5
        linePath.stroke()
        
        let footerAppNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: context.configuration.secondaryColor
        ]
        
        let appNameRect = CGRect(x: margin, y: footerY, width: 200, height: 20)
        context.configuration.appName.draw(in: appNameRect, withAttributes: footerAppNameAttributes)
        
        let pageText = "Page \(pageNumber) of \(totalPages)"
        let pageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: context.configuration.secondaryColor
        ]
        
        let pageTextSize = pageText.size(withAttributes: pageAttributes)
        let pageRect = CGRect(
            x: pageSize.width - margin - pageTextSize.width,
            y: footerY,
            width: pageTextSize.width,
            height: 20
        )
        pageText.draw(in: pageRect, withAttributes: pageAttributes)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateText = "Generated: \(dateFormatter.string(from: Date()))"
        
        let dateTextSize = dateText.size(withAttributes: pageAttributes)
        let centerX = (pageSize.width - dateTextSize.width) / 2
        let dateRect = CGRect(x: centerX, y: footerY, width: dateTextSize.width, height: 20)
        dateText.draw(in: dateRect, withAttributes: pageAttributes)
    }

}
