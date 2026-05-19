CREATE DATABASE YemekSiparisPlatformu;
GO

USE YemekSiparisPlatformu;
GO

CREATE TABLE Musteri (
    MusteriID           INT IDENTITY(1,1) PRIMARY KEY,
    Ad                  NVARCHAR(50)  NOT NULL,
    Soyad               NVARCHAR(50)  NOT NULL,
    Email               NVARCHAR(100) NOT NULL UNIQUE,
    Telefon             NVARCHAR(15)  NOT NULL UNIQUE,
    SifreHash           NVARCHAR(256) NOT NULL,
    KayitTarihi         DATETIME      NOT NULL DEFAULT GETDATE(),
    IhtiyacSahibiMi     BIT           NOT NULL DEFAULT 0,
    IhtiyacDogrulandiMi BIT           NOT NULL DEFAULT 0,
    IsActive            BIT           NOT NULL DEFAULT 1
);
GO

CREATE TABLE Adres (
    AdresID      INT IDENTITY(1,1) PRIMARY KEY,
    MusteriID    INT           NOT NULL,
    AdresBasligi NVARCHAR(50)  NOT NULL,
    AdresTarifi  NVARCHAR(300) NOT NULL,
    Ilce         NVARCHAR(50)  NOT NULL,
    Sehir        NVARCHAR(50)  NOT NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,

    CONSTRAINT FK_Adres_Musteri FOREIGN KEY (MusteriID)
        REFERENCES Musteri(MusteriID)
);
GO

CREATE TABLE Restoran (
    RestoranID    INT IDENTITY(1,1) PRIMARY KEY,
    RestoranAdi   NVARCHAR(100) NOT NULL,
    Email         NVARCHAR(100) NOT NULL UNIQUE,
    Telefon       NVARCHAR(15)  NOT NULL UNIQUE,
    Sehir         NVARCHAR(50)  NOT NULL,
    Ilce          NVARCHAR(50)  NOT NULL,
    AcilisSaati   TIME          NOT NULL DEFAULT '09:00:00',
    KapanisSaati  TIME          NOT NULL DEFAULT '22:00:00',
    RestoranPuani DECIMAL(3,2)  NOT NULL DEFAULT 0.00,
    ToplamCiro    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    IsActive      BIT           NOT NULL DEFAULT 1,

    CONSTRAINT CHK_Restoran_Puani CHECK (RestoranPuani BETWEEN 0 AND 5),
    CONSTRAINT CHK_Restoran_Ciro  CHECK (ToplamCiro >= 0)
);
GO

CREATE TABLE Kategori (
    KategoriID  INT IDENTITY(1,1) PRIMARY KEY,
    KategoriAdi NVARCHAR(50) NOT NULL UNIQUE,
    IsActive    BIT          NOT NULL DEFAULT 1
);
GO

CREATE TABLE Urun (
    UrunID     INT IDENTITY(1,1) PRIMARY KEY,
    RestoranID INT           NOT NULL,
    KategoriID INT           NOT NULL,
    UrunAdi    NVARCHAR(100) NOT NULL,
    Fiyat      DECIMAL(8,2)  NOT NULL,
    Aciklama   NVARCHAR(300) NULL,
    IsActive   BIT           NOT NULL DEFAULT 1,

    CONSTRAINT CHK_Urun_Fiyat   CHECK (Fiyat > 0),
    CONSTRAINT FK_Urun_Restoran FOREIGN KEY (RestoranID) REFERENCES Restoran(RestoranID),
    CONSTRAINT FK_Urun_Kategori FOREIGN KEY (KategoriID) REFERENCES Kategori(KategoriID)
);
GO

CREATE TABLE Kurye (
    KuryeID  INT IDENTITY(1,1) PRIMARY KEY,
    Ad       NVARCHAR(50) NOT NULL,
    Soyad    NVARCHAR(50) NOT NULL,
    Telefon  NVARCHAR(15) NOT NULL UNIQUE,
    AracTipi NVARCHAR(30) NOT NULL DEFAULT 'Motorsiklet',
    MevcutMu BIT          NOT NULL DEFAULT 1,
    IsActive BIT          NOT NULL DEFAULT 1
);
GO