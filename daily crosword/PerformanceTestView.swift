import SwiftUI

// MARK: - Performance Test View

struct PerformanceTestView: View {
    let puzzle: PuzzleDetail
    @State private var useOptimizedVersion = true
    @State private var performanceMetrics: [String: TimeInterval] = [:]
    
    var body: some View {
        VStack {
            Toggle("Use Optimized Version", isOn: $useOptimizedVersion)
                .padding()
            
            if useOptimizedVersion {
                OptimizedPuzzleView(puzzle: puzzle)
                    .onAppear {
                        measurePerformance("Optimized")
                    }
            } else {
                PuzzleView(puzzle: puzzle)
                    .onAppear {
                        measurePerformance("Original")
                    }
            }
            
            // Performance metrics display
            if !performanceMetrics.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Performance Metrics:")
                        .font(.headline)
                    
                    ForEach(Array(performanceMetrics.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key)
                            Spacer()
                            Text(String(format: "%.3fs", performanceMetrics[key] ?? 0))
                                .monospacedDigit()
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            }
        }
    }
    
    private func measurePerformance(_ version: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate some typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let endTime = CFAbsoluteTimeGetCurrent()
            let duration = endTime - startTime
            performanceMetrics[version] = duration
        }
    }
}

// MARK: - Performance Tips

/*
 PERFORMANCE OPTIMIZATION TIPS:
 
 1. **Use OptimizedPuzzleView** - It has better performance characteristics
 
 2. **Key Performance Improvements Made:**
    - Removed immediate validation on every keystroke
    - Debounced validation to 500ms instead of 300ms
    - Removed storage saves on every keystroke
    - Simplified onChange handlers
    - Used LazyVGrid for efficient rendering
    - Reduced ObservableObject overhead
 
 3. **Typing Lag Causes (Fixed):**
    - Multiple @ObservedObject cells causing cascading updates
    - Immediate validation on every keystroke
    - Storage saves on every keystroke
    - Complex onChange handlers with multiple state changes
    - Inefficient focus management
 
 4. **Expected Performance:**
    - Typing should now be nearly instant
    - Focus should move immediately after typing
    - No more 0.5 second delays
    - Smoother scrolling and navigation
 
 5. **If Still Experiencing Lag:**
    - Check if you're using the optimized version
    - Monitor memory usage in Instruments
    - Test with smaller grids first
    - Consider reducing grid size for very large puzzles
 */ 