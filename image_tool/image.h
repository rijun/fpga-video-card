#ifndef IMAGE_H
#define IMAGE_H

#include <QString>
#include <QVector>

class QImage;
class QPixmap;
class QSize;

class Image
{
public:
    Image();
    ~Image();

    static QPixmap preview(const QImage &image);
    static QPixmap preview(const QImage &image, QSize size);

    const QImage &image() const;
    bool setImage(const QString &path);
    const QImage &reducedImage() const;
    const QImage reducedImageDisplay() const;

private:
    QImage *m_image;
    QImage *m_imageReduced;

    QVector<unsigned int> m_colorMap;
    QVector<unsigned int> m_colorMapDisplay;

    bool generateReducedImage();
    int map(int value, int inMin = 0, int inMax = 255, int outMin = 0, int outMax = 15);
};

#endif // IMAGE_H
