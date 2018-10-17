// Copyright 2018 The VGC Developers
// See the COPYRIGHT file at the top-level directory of this distribution
// and at https://github.com/vgc/vgc/blob/master/COPYRIGHT
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef VGC_WIDGETS_PERFORMANCEMONITOR_H
#define VGC_WIDGETS_PERFORMANCEMONITOR_H

#include <QWidget>
#include <vgc/widgets/api.h>

class QLabel;

namespace vgc {
namespace widgets {

/// \class vgc::widgets::PerformanceMonitor
/// \brief A panel that displays performance information (rendering time, etc.)
///
class VGC_WIDGETS_API PerformanceMonitor : public QWidget
{
private:
    Q_OBJECT
    Q_DISABLE_COPY(PerformanceMonitor)

public:
    /// Creates a PerformanceMonitor.
    ///
    PerformanceMonitor(QWidget* parent = nullptr);

    /// Destroys the PerformanceMonitor.
    ///
    ~PerformanceMonitor() override;

    /// Sets the last rendering time.
    ///
    void setRenderingTime(double t);

private:
    QLabel* renderingTime_;
};

} // namespace widgets
} // namespace vgc

#endif // VGC_WIDGETS_PERFORMANCEMONITOR_H
