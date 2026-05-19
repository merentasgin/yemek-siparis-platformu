CREATE TABLE Siparis (
    SiparisID     INT IDENTITY(1,1) PRIMARY KEY,
    MusteriID     INT           NOT NULL,
    RestoranID    INT           NOT NULL,
    KuryeID       INT           NULL,
    AdresID       INT           NOT NULL,
    SiparisTarihi DATETIME      NOT NULL DEFAULT GETDATE(),
    ToplamTutar   DECIMAL(10,2) NOT NULL,
    Durum         NVARCHAR(20)  NOT NULL DEFAULT 'Bekliyor',
    OdemeYontemi  NVARCHAR(20)  NOT NULL DEFAULT 'Nakit',
    AskidanMi     BIT           NOT NULL DEFAULT 0,
    IsActive      BIT           NOT NULL DEFAULT 1,

    CONSTRAINT CHK_Siparis_Tutar CHECK (ToplamTutar > 0),
    CONSTRAINT CHK_Siparis_Durum CHECK (
        Durum IN ('Bekliyor','Hazirlaniyor','Yolda','TeslimEdildi','Iptal')
    ),
    CONSTRAINT CHK_Siparis_Odeme CHECK (
        OdemeYontemi IN ('Nakit','KrediKarti','Havuz')
    ),
    CONSTRAINT FK_Siparis_Musteri  FOREIGN KEY (MusteriID)  REFERENCES Musteri(MusteriID),
    CONSTRAINT FK_Siparis_Restoran FOREIGN KEY (RestoranID) REFERENCES Restoran(RestoranID),
    CONSTRAINT FK_Siparis_Kurye    FOREIGN KEY (KuryeID)    REFERENCES Kurye(KuryeID),
    CONSTRAINT FK_Siparis_Adres    FOREIGN KEY (AdresID)    REFERENCES Adres(AdresID)
);
GO

CREATE TABLE SiparisDetay (
    DetayID    INT IDENTITY(1,1) PRIMARY KEY,
    SiparisID  INT          NOT NULL,
    UrunID     INT          NOT NULL,
    Miktar     INT          NOT NULL DEFAULT 1,
    BirimFiyat DECIMAL(8,2) NOT NULL,
    IsActive   BIT          NOT NULL DEFAULT 1,

    CONSTRAINT CHK_DetayMiktar CHECK (Miktar >= 1),
    CONSTRAINT CHK_DetayFiyat  CHECK (BirimFiyat > 0),
    CONSTRAINT FK_SiparisDetay_Siparis FOREIGN KEY (SiparisID) REFERENCES Siparis(SiparisID),
    CONSTRAINT FK_SiparisDetay_Urun    FOREIGN KEY (UrunID)    REFERENCES Urun(UrunID)
);
GO

CREATE TABLE AskidaHavuz (
    HavuzID           INT           PRIMARY KEY DEFAULT 1,
    ToplamBakiye      DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ToplamBagis       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ToplamKullanim    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    GuncellenmeTarihi DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CHK_Havuz_Bakiye CHECK (ToplamBakiye >= 0)
);
GO

INSERT INTO AskidaHavuz (HavuzID, ToplamBakiye, ToplamBagis, ToplamKullanim)
VALUES (1, 0.00, 0.00, 0.00);
GO

CREATE TABLE AskidaBagis (
    BagisID     INT IDENTITY(1,1) PRIMARY KEY,
    MusteriID   INT           NULL,
    UrunID      INT           NULL,
    Tutar       DECIMAL(10,2) NOT NULL,
    BagisTarihi DATETIME      NOT NULL DEFAULT GETDATE(),
    GizliMi     BIT           NOT NULL DEFAULT 0,
    Aciklama    NVARCHAR(200) NULL,

    CONSTRAINT CHK_Bagis_Tutar CHECK (Tutar > 0),
    CONSTRAINT FK_AskidaBagis_Musteri FOREIGN KEY (MusteriID) REFERENCES Musteri(MusteriID),
    CONSTRAINT FK_AskidaBagis_Urun    FOREIGN KEY (UrunID)    REFERENCES Urun(UrunID)
);
GO

CREATE TABLE AskidaKullanim (
    KullanimID     INT IDENTITY(1,1) PRIMARY KEY,
    MusteriID      INT           NOT NULL,
    SiparisID      INT           NOT NULL,
    Tutar          DECIMAL(10,2) NOT NULL,
    KullanimTarihi DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CHK_Kullanim_Tutar CHECK (Tutar > 0),
    CONSTRAINT FK_AskidaKullanim_Musteri FOREIGN KEY (MusteriID) REFERENCES Musteri(MusteriID),
    CONSTRAINT FK_AskidaKullanim_Siparis FOREIGN KEY (SiparisID) REFERENCES Siparis(SiparisID)
);
GO

CREATE TABLE IhtiyacDogrulama (
    DogrulamaID      INT IDENTITY(1,1) PRIMARY KEY,
    MusteriID        INT           NOT NULL,
    DogrulayiciNot   NVARCHAR(500) NULL,
    BasvuruTarihi    DATETIME      NOT NULL DEFAULT GETDATE(),
    DogrulanmaTarihi DATETIME      NULL,
    Durum            NVARCHAR(20)  NOT NULL DEFAULT 'Bekliyor',

    CONSTRAINT CHK_Dogrulama_Durum CHECK (
        Durum IN ('Bekliyor','Onaylandi','Reddedildi')
    ),
    CONSTRAINT FK_IhtiyacDogrulama_Musteri FOREIGN KEY (MusteriID)
        REFERENCES Musteri(MusteriID)
);
GO
