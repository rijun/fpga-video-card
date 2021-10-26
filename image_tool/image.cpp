#include "image.h"

#include <QDebug>
#include <QImage>
#include <QPixmap>

Image::Image() : m_image(new QImage), m_imageReduced(new QImage)
{


    // Create color mapping for display
    m_colorMapDisplay.fill(0, 16);
    for (int i = 0; i < m_colorMapDisplay.size(); ++i) {
        m_colorMapDisplay[i] = 16 * i;
    }
}

Image::~Image()
{
    delete m_imageReduced;
    delete m_image;
}

QPixmap Image::preview(const QImage &image)
{
    return QPixmap::fromImage(image);
}

QPixmap Image::preview(const QImage &image, QSize size)
{
    QImage imgScaled = image.scaled(size, Qt::AspectRatioMode::KeepAspectRatio, Qt::TransformationMode::SmoothTransformation);
    return QPixmap::fromImage(imgScaled);
}

const QImage &Image::image() const
{
    return *m_image;
}

bool Image::setImage(const QString &path)
{
    if (!m_image->load(path)) {
        return false;
    }

    if (!generateReducedImage()) {
        return false;
    }

    return true;
}

const QImage &Image::reducedImage() const
{
    return *m_imageReduced;
}

const QImage Image::reducedImageDisplay() const
{
    QImage reduced(m_imageReduced->size(), m_imageReduced->format());
    for (int x = 0; x < m_imageReduced->width(); ++x) {
        for (int y = 0; y < m_imageReduced->height(); ++y) {
            QColor oldColor = m_imageReduced->pixel(x, y);
            QColor newColor = QColor(
                        m_colorMapDisplay[oldColor.red()],
                        m_colorMapDisplay[oldColor.green()],
                        m_colorMapDisplay[oldColor.blue()]
                    );
            reduced.setPixel(x, y, newColor.rgb());
        }
    }
    return reduced;
}

bool Image::generateReducedImage()
{
    *m_imageReduced = m_image->scaled(QSize(384, 224), Qt::AspectRatioMode::KeepAspectRatio, Qt::TransformationMode::SmoothTransformation);

    for (int x = 0; x < m_imageReduced->width(); ++x) {
        for (int y = 0; y < m_imageReduced->height(); ++y) {
            QColor oldColor = m_imageReduced->pixel(x, y);

            if (oldColor.red() > 255 || oldColor.green() > 255 || oldColor.blue() > 255) {
                qDebug() << "Wasted";
                return false;
            }

            QColor newColor = QColor(
                        map(oldColor.red()),
                        map(oldColor.green()),
                        map(oldColor.blue())
                    );
            m_imageReduced->setPixel(x, y, newColor.rgb());
        }
    }

    return true;
}

int Image::map(int value, int inMin, int inMax, int outMin, int outMax)
{
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}
