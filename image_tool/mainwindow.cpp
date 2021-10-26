#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QFileDialog>
#include <QTextStream>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    connect(ui->loadButton, &QPushButton::clicked, this, &MainWindow::loadFile);
    connect(ui->exportButton, &QPushButton::clicked, this, &MainWindow::exportCoeFile);
    emit ui->loadButton->clicked();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::loadFile()
{
    QString fileName = QFileDialog::getOpenFileName(this, tr("Open Image"), ".", tr("Image Files (*.png *.jpg *.bmp)"));
    bool loadSuccessful = m_image.setImage(fileName);

    if (!loadSuccessful) {
        return;
    }

    ui->imageView->setPixmap(Image::preview(m_image.image(), ui->imageView->size()));
    ui->imageReducedView->setPixmap(Image::preview(m_image.reducedImageDisplay()));
}

void MainWindow::exportCoeFile()
{
    int imageByteSize = m_image.reducedImage().width() * m_image.reducedImage().height() * 3;
    QVector<int> flattenedImage;
    for (int y = 0; y < m_image.reducedImage().height(); ++y) {
        for (int x = 0; x < m_image.reducedImage().width(); ++x) {
            flattenedImage.append(m_image.reducedImage().pixelColor(x, y).red());
            flattenedImage.append(m_image.reducedImage().pixelColor(x, y).green());
            flattenedImage.append(m_image.reducedImage().pixelColor(x, y).blue());
        }
    }
    assert(flattenedImage.size() == imageByteSize);

    QString fileName = QFileDialog::getSaveFileName(this, tr("Save .coe File"), ".", tr("Coefficiant file (*.coe)"));
    QFile file(fileName);
    if (file.open(QFile::WriteOnly | QFile::Truncate)) {
        QTextStream out(&file);

        out << "memory_initialization_radix=16;" << Qt::endl;
        out << "memory_initialization_vector=" << Qt::endl;
        out.setIntegerBase(16);
        out.setPadChar('0');
        for (int i = 0; i + 4 < flattenedImage.size(); i += 4) {
            out << qSetFieldWidth(2) << flattenedImage[i+3] << flattenedImage[i+2] << flattenedImage[i+1] << flattenedImage[i];
            out << qSetFieldWidth(1) << ',' << Qt::endl;
        }
        out << ';' << Qt::endl;
    }
    file.close();
}
