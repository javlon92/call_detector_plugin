import os
import Foundation

/// Унифицированный логгер с цветным выводом, приватностью, логированием в файл и автоочисткой.
enum Log {
    
    // MARK: - Конфигурация
    
    /// Подсистема — обычно bundle ID
    private static let subsystem = "com.example.call_detector_plugin"
    
    /// Включить/отключить логирование (вкл только в Debug)
#if DEBUG
    private static let isEnabled = true
    private static let isFileLoggingEnabled = false
#else
    private static let isEnabled = false
    private static let isFileLoggingEnabled = false
#endif
    
    /// Максимальный размер файла логов (в байтах). По умолчанию — 512 KB.
    private static let maxFileSizeBytes: UInt64 = 512 * 1024
    
    // MARK: - Публичные API
    
    /// Лог `debug` уровня
    static func debug(_ message: String, tag: String? = nil,
                      isPrivate: Bool = false,
                      function: String = #function,
                      line: Int = #line, file: String = #fileID) {
        log(message, tag: tag, file: file, function: function, line: line, level: .debug, isPrivate: isPrivate)
    }
    
    /// Лог `info` уровня
    static func info(_ message: String, tag: String? = nil,
                     isPrivate: Bool = false,
                     function: String = #function,
                     line: Int = #line, file: String = #fileID) {
        log(message, tag: tag, file: file, function: function, line: line, level: .info, isPrivate: isPrivate)
    }
    
    /// Лог `error` уровня
    static func error(_ message: String, tag: String? = nil,
                      isPrivate: Bool = false,
                      function: String = #function,
                      line: Int = #line, file: String = #fileID) {
        log(message, tag: tag, file: file, function: function, line: line, level: .error, isPrivate: isPrivate)
    }
    
    /// Лог `fault` уровня
    static func fault(_ message: String, tag: String? = nil,
                      isPrivate: Bool = false,
                      function: String = #function,
                      line: Int = #line, file: String = #fileID) {
        log(message, tag: tag, file: file, function: function, line: line, level: .fault, isPrivate: isPrivate)
    }
    
    /// Нейтральный `trace-лог` (служебный, без уровня)
    static func trace(_ message: String, tag: String? = nil,
                      isPrivate: Bool = false,
                      function: String = #function,
                      line: Int = #line, file: String = #fileID) {
        log(message, tag: tag, file: file, function: function, line: line, level: .default, isPrivate: isPrivate)
    }
    
    // MARK: - Внутренняя реализация
    
    private static func log(_ message: String, tag: String?, file: String, function: String, line: Int,
                            level: OSLogType,
                            isPrivate: Bool) {
        guard isEnabled else { return }
        let category = simplified(tag ?? file)
        let composedMessage = "[\(function):\(line)] \(message)"
        
        // iOS 14+: Используем `Logger`
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: subsystem, category: category)
            let emoji = emojiPrefix(for: level)
            let coloredMessage = coloredText("\(emoji) \(composedMessage)", level: level)
            
            // Используем if else, чтобы обойти ограничение интерполяции с privacy:
            if isPrivate {
                switch level {
                case .debug: logger.debug("\(coloredMessage, privacy: .private)")
                case .info: logger.info("\(coloredMessage, privacy: .private)")
                case .error: logger.error("\(coloredMessage, privacy: .private)")
                case .fault: logger.fault("\(coloredMessage, privacy: .private)")
                default: logger.log("\(coloredMessage, privacy: .private)")
                }
            } else {
                switch level {
                case .debug: logger.debug("\(coloredMessage, privacy: .public)")
                case .info: logger.info("\(coloredMessage, privacy: .public)")
                case .error: logger.error("\(coloredMessage, privacy: .public)")
                case .fault: logger.fault("\(coloredMessage, privacy: .public)")
                default: logger.log("\(coloredMessage, privacy: .public)")
                }
            }
        } else {
            // iOS 13-: Используем print
            let emoji = emojiPrefix(for: level)
            let coloredMessage = coloredText("[\(category)] \(emoji) \(composedMessage)", level: level)
            print(coloredMessage)
        }
        
#if DEBUG
        if isFileLoggingEnabled {
            appendToFile("[\(category)] \(composedMessage)")
        }
#endif
    }
    
    /// Упрощает имя файла до категории
    private static func simplified(_ raw: String) -> String {
        let fileName = raw.components(separatedBy: "/").last ?? raw
        return fileName.components(separatedBy: ".").first ?? fileName
    }
    
    
    // MARK: - DEBUG Helpers
    
#if DEBUG
    
    private static func coloredText(_ text: String, level: OSLogType) -> String {
        
        // В симуляторе или Xcode — без цвета
        return text
        
        /*
         // В терминале — с цветом ANSI
         let color: String
         switch level {
         case .debug: color = "\u{001B}[0;37m" // gray
         case .info:  color = "\u{001B}[0;34m" // blue
         case .error: color = "\u{001B}[0;31m" // red
         case .fault: color = "\u{001B}[0;35m" // magenta
         default:     color = "\u{001B}[0;0m"  // reset
         }
         return "\(color)\(text)\u{001B}[0;0m"
         */
    }
    
    /// Эмодзи перед сообщением
    private static func emojiPrefix(for level: OSLogType) -> String {
        switch level {
        case .debug: return "💬"
        case .info:  return "ℹ️"
        case .error: return "❗️"
        case .fault: return "💥"
        default:     return "🔹"
        }
    }
    
    /// Путь к файлу логов
    private static var logFileURL: URL? {
        guard let base = try? FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Logs", isDirectory: true) else {
            return nil
        }
        
        if !FileManager.default.fileExists(atPath: base.path) {
            try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        }
        
        return base.appendingPathComponent("log.txt")
    }
    
    /// Добавляет строку в файл логов
    private static func appendToFile(_ text: String) {
        guard let url = logFileURL else { return }
        
        if exceedsMaxSize(url) {
            try? FileManager.default.removeItem(at: url)
        }
        
        let line = "\(Date()): \(text)\n"
        guard let data = line.data(using: .utf8) else { return }
        
        if FileManager.default.fileExists(atPath: url.path),
           let handle = try? FileHandle(forWritingTo: url) {
            
            handle.seekToEndOfFile()
            if #available(iOS 13.4, *) {
                try? handle.write(contentsOf: data)
            } else {
                handle.write(data)
            }
            
            if #available(iOS 13.0, *) {
                try? handle.close()
            } else {
                handle.closeFile()
            }
            
        } else {
            try? data.write(to: url)
        }
    }
    
    /// Проверяет, превышает ли файл лимит
    private static func exceedsMaxSize(_ url: URL) -> Bool {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? UInt64 else {
            return false
        }
        return size > maxFileSizeBytes
    }
#endif
}
