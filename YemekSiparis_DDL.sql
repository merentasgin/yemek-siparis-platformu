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
USE YemekSiparisPlatformu;
GO

INSERT INTO Kategori (KategoriAdi) VALUES
('Pizza'),('Burger'),('Sushi'),('Döner'),('Izgara'),
('Makarna'),('Tatlı'),('İçecek'),('Kahvaltı'),('Salata');
GO

INSERT INTO Restoran (RestoranAdi, Email, Telefon, Sehir, Ilce, AcilisSaati, KapanisSaati, RestoranPuani, ToplamCiro) VALUES
('Lezzet Durağı',   'info@lezzetduragi.com',  '05301234567', 'İstanbul', 'Kadıköy',  '09:00', '23:00', 4.50, 0.00),
('Burger Noktası',  'info@burgernoktasi.com',  '05302234568', 'İstanbul', 'Beşiktaş', '10:00', '23:00', 4.20, 0.00),
('Sushi Bahçesi',   'info@sushibahcesi.com',   '05303234569', 'Ankara',   'Çankaya',  '11:00', '22:00', 4.70, 0.00),
('Anadolu Sofrası', 'info@anadolusofrasi.com', '05304234570', 'İzmir',    'Konak',    '08:00', '22:00', 4.10, 0.00),
('Pizza Kulesi',    'info@pizzakulesi.com',    '05305234571', 'İstanbul', 'Üsküdar',  '10:00', '23:30', 4.40, 0.00);
GO

INSERT INTO Musteri (Ad, Soyad, Email, Telefon, SifreHash, IhtiyacSahibiMi, IhtiyacDogrulandiMi) VALUES
('Ahmet',   'Yılmaz',  'ahmet.yilmaz@gmail.com',  '05311234567', 'hash1',  0, 0),
('Ayşe',    'Kaya',    'ayse.kaya@gmail.com',      '05312234568', 'hash2',  0, 0),
('Mehmet',  'Demir',   'mehmet.demir@gmail.com',   '05313234569', 'hash3',  0, 0),
('Fatma',   'Çelik',   'fatma.celik@gmail.com',    '05314234570', 'hash4',  0, 0),
('Ali',     'Şahin',   'ali.sahin@gmail.com',      '05315234571', 'hash5',  0, 0),
('Zeynep',  'Yıldız',  'zeynep.yildiz@gmail.com',  '05316234572', 'hash6',  0, 0),
('Mustafa', 'Arslan',  'mustafa.arslan@gmail.com', '05317234573', 'hash7',  0, 0),
('Elif',    'Doğan',   'elif.dogan@gmail.com',     '05318234574', 'hash8',  0, 0),
('Hasan',   'Kılıç',   'hasan.kilic@gmail.com',    '05319234575', 'hash9',  0, 0),
('Merve',   'Aydın',   'merve.aydin@gmail.com',    '05310234576', 'hash10', 0, 0),
('İbrahim', 'Özkan',   'ibrahim.ozkan@gmail.com',  '05321234577', 'hash11', 0, 0),
('Selin',   'Erdoğan', 'selin.erdogan@gmail.com',  '05322234578', 'hash12', 0, 0),
('Burak',   'Koç',     'burak.koc@gmail.com',      '05323234579', 'hash13', 0, 0),
('Derya',   'Kurt',    'derya.kurt@gmail.com',     '05324234580', 'hash14', 0, 0),
('Emre',    'Güneş',   'emre.gunes@gmail.com',     '05325234581', 'hash15', 0, 0),
('Tuğba',   'Polat',   'tugba.polat@gmail.com',    '05326234582', 'hash16', 0, 0),
('Serkan',  'Acar',    'serkan.acar@gmail.com',    '05327234583', 'hash17', 0, 0),
('Gamze',   'Bulut',   'gamze.bulut@gmail.com',    '05328234584', 'hash18', 0, 0),
('Oğuz',    'Güler',   'oguz.guler@gmail.com',     '05329234585', 'hash19', 1, 1),
('Hatice',  'Çetin',   'hatice.cetin@gmail.com',   '05320234586', 'hash20', 1, 1);
GO

INSERT INTO Adres (MusteriID, AdresBasligi, AdresTarifi, Ilce, Sehir) VALUES
(1,  'Ev', 'Moda Cad. No:12 Daire:3',      'Kadıköy',   'İstanbul'),
(2,  'Ev', 'Bağdat Cad. No:45 Daire:7',    'Kadıköy',   'İstanbul'),
(3,  'İş', 'Barbaros Blv. No:23 Kat:4',    'Beşiktaş',  'İstanbul'),
(4,  'Ev', 'Tunalı Hilmi Cad. No:67',      'Çankaya',   'Ankara'),
(5,  'Ev', 'Kıbrıs Şehitleri Cad. No:89',  'Konak',     'İzmir'),
(6,  'Ev', 'Bağlarbaşı Sok. No:5 Daire:2', 'Üsküdar',   'İstanbul'),
(7,  'İş', 'Atatürk Cad. No:34 Kat:2',     'Çankaya',   'Ankara'),
(8,  'Ev', 'Cumhuriyet Cad. No:11',        'Konak',     'İzmir'),
(9,  'Ev', 'İstiklal Cad. No:78 Daire:5',  'Beyoğlu',   'İstanbul'),
(10, 'Ev', 'Halaskargazi Cad. No:90',      'Şişli',     'İstanbul'),
(11, 'Ev', 'Bağdat Cad. No:102 Daire:8',   'Kadıköy',   'İstanbul'),
(12, 'İş', 'Nispetiye Cad. No:15 Kat:3',   'Beşiktaş',  'İstanbul'),
(13, 'Ev', 'Tunalı Hilmi Cad. No:44',      'Çankaya',   'Ankara'),
(14, 'Ev', 'Alsancak Cad. No:56 Daire:1',  'Konak',     'İzmir'),
(15, 'Ev', 'Moda Cad. No:33 Daire:6',      'Kadıköy',   'İstanbul'),
(16, 'İş', 'Barbaros Blv. No:77 Kat:5',    'Beşiktaş',  'İstanbul'),
(17, 'Ev', 'Kızılay Mah. No:21 Daire:3',   'Çankaya',   'Ankara'),
(18, 'Ev', 'Karşıyaka Cad. No:14',         'Karşıyaka', 'İzmir'),
(19, 'Ev', 'Fikirtepe Mah. No:8 Daire:2',  'Kadıköy',   'İstanbul'),
(20, 'Ev', 'Göztepe Mah. No:19 Daire:4',   'Kadıköy',   'İstanbul');
GO

INSERT INTO Kurye (Ad, Soyad, Telefon, AracTipi, MevcutMu) VALUES
('Kadir',  'Yılmaz', '05331234567', 'Motorsiklet', 1),
('Serdar', 'Kaya',   '05332234568', 'Motorsiklet', 1),
('Tolga',  'Demir',  '05333234569', 'Bisiklet',    1),
('Murat',  'Çelik',  '05334234570', 'Motorsiklet', 0),
('Volkan', 'Arslan', '05335234571', 'Otomobil',    1);
GO

INSERT INTO Urun (RestoranID, KategoriID, UrunAdi, Fiyat, Aciklama) VALUES
(1, 1,  'Karışık Pizza',        120.00, 'Özel sos ve malzemeli'),
(1, 1,  'Margarita Pizza',      100.00, 'Domates soslu klasik'),
(1, 6,  'Fettuccine Alfredo',   110.00, 'Kremalı makarna'),
(1, 6,  'Bolognese',             95.00, 'Kıymalı domates soslu'),
(1, 10, 'Mevsim Salatası',       65.00, 'Taze sebzeler'),
(1, 8,  'Ayran',                 20.00, NULL),
(1, 8,  'Cola',                  25.00, NULL),
(1, 8,  'Su',                    10.00, NULL),
(1, 7,  'Tiramisu',              75.00, 'İtalyan tatlısı'),
(1, 7,  'Cheesecake',            70.00, 'New York usulü'),
(2, 2,  'Klasik Burger',         95.00, 'Dana eti, cheddar, sos'),
(2, 2,  'Crispy Chicken Burger', 90.00, 'Çıtır tavuk'),
(2, 2,  'Double Burger',        130.00, 'Çift katlı dana eti'),
(2, 2,  'Vejetaryen Burger',     85.00, 'Sebze köftesi'),
(2, 10, 'Coleslaw Salata',       45.00, NULL),
(2, 8,  'Milkshake',             55.00, 'Çikolata veya çilek'),
(2, 8,  'Limonata',              35.00, NULL),
(2, 7,  'Brownie',               60.00, 'Sıcak çikolatalı'),
(2, 8,  'Ayran',                 20.00, NULL),
(2, 8,  'Cola',                  25.00, NULL),
(3, 3,  'Somon Nigiri',         150.00, '2 adet'),
(3, 3,  'Ton Balığı Maki',      130.00, '6 adet'),
(3, 3,  'California Roll',      140.00, '8 adet'),
(3, 3,  'Spicy Tuna Roll',      145.00, '8 adet'),
(3, 3,  'Veggie Roll',          110.00, '8 adet'),
(3, 10, 'Miso Çorbası',          55.00, NULL),
(3, 8,  'Japon Çayı',            30.00, NULL),
(3, 8,  'Su',                    10.00, NULL),
(3, 7,  'Mochi Dondurma',        80.00, 'Japon tatlısı'),
(3, 8,  'Limonata',              35.00, NULL),
(4, 4,  'Tavuk Döner',           85.00, 'Lavaş ekmekli'),
(4, 4,  'Et Döner',              95.00, 'Lavaş ekmekli'),
(4, 4,  'Karışık Döner',        100.00, 'Tavuk ve et'),
(4, 5,  'Adana Kebap',          130.00, 'Acılı kıyma kebabı'),
(4, 5,  'Urfa Kebap',           125.00, 'Acısız kıyma kebabı'),
(4, 5,  'Tavuk Izgara',         110.00, NULL),
(4, 9,  'Serpme Kahvaltı',      180.00, 'İki kişilik'),
(4, 10, 'Çoban Salatası',        50.00, NULL),
(4, 8,  'Ayran',                 20.00, NULL),
(4, 8,  'Şalgam',                20.00, NULL),
(5, 1,  'Pepperoni Pizza',      115.00, NULL),
(5, 1,  'Dört Peynirli Pizza',  125.00, NULL),
(5, 1,  'Tavuklu Pizza',        110.00, NULL),
(5, 1,  'Vejeteryan Pizza',     105.00, NULL),
(5, 1,  'BBQ Pizza',            120.00, NULL),
(5, 6,  'Penne Arrabbiata',      90.00, 'Acı domates soslu'),
(5, 7,  'Profiterol',            65.00, NULL),
(5, 8,  'Ayran',                 20.00, NULL),
(5, 8,  'Cola',                  25.00, NULL),
(5, 8,  'Meyve Suyu',            30.00, NULL);
GO

INSERT INTO Siparis (MusteriID, RestoranID, KuryeID, AdresID, ToplamTutar, Durum, OdemeYontemi, AskidanMi) VALUES
(1,  1, 1, 1,  145.00, 'TeslimEdildi', 'KrediKarti', 0),
(2,  2, 2, 2,  190.00, 'TeslimEdildi', 'KrediKarti', 0),
(3,  3, 3, 3,  280.00, 'TeslimEdildi', 'Nakit',      0),
(4,  4, 4, 4,  215.00, 'TeslimEdildi', 'KrediKarti', 0),
(5,  5, 5, 5,  235.00, 'TeslimEdildi', 'Nakit',      0),
(6,  1, 1, 6,  120.00, 'TeslimEdildi', 'KrediKarti', 0),
(7,  2, 2, 7,  175.00, 'TeslimEdildi', 'Nakit',      0),
(8,  3, 3, 8,  290.00, 'TeslimEdildi', 'KrediKarti', 0),
(9,  4, 1, 9,  180.00, 'TeslimEdildi', 'Nakit',      0),
(10, 5, 2, 10, 240.00, 'TeslimEdildi', 'KrediKarti', 0),
(1,  2, 3, 1,  220.00, 'TeslimEdildi', 'KrediKarti', 0),
(2,  3, 4, 2,  310.00, 'TeslimEdildi', 'Nakit',      0),
(3,  4, 5, 3,  195.00, 'TeslimEdildi', 'KrediKarti', 0),
(4,  5, 1, 4,  250.00, 'TeslimEdildi', 'Nakit',      0),
(5,  1, 2, 5,  165.00, 'TeslimEdildi', 'KrediKarti', 0),
(6,  2, 3, 6,  200.00, 'TeslimEdildi', 'KrediKarti', 0),
(7,  3, 4, 7,  275.00, 'TeslimEdildi', 'Nakit',      0),
(8,  4, 5, 8,  230.00, 'TeslimEdildi', 'KrediKarti', 0),
(9,  5, 1, 9,  185.00, 'TeslimEdildi', 'Nakit',      0),
(10, 1, 2, 10, 140.00, 'TeslimEdildi', 'KrediKarti', 0),
(11, 2, 3, 11, 210.00, 'TeslimEdildi', 'KrediKarti', 0),
(12, 3, 4, 12, 295.00, 'TeslimEdildi', 'Nakit',      0),
(13, 4, 5, 13, 175.00, 'TeslimEdildi', 'KrediKarti', 0),
(14, 5, 1, 14, 245.00, 'TeslimEdildi', 'Nakit',      0),
(15, 1, 2, 15, 130.00, 'TeslimEdildi', 'KrediKarti', 0),
(16, 2, 3, 16, 220.00, 'TeslimEdildi', 'KrediKarti', 0),
(17, 3, 4, 17, 260.00, 'TeslimEdildi', 'Nakit',      0),
(18, 4, 5, 18, 195.00, 'TeslimEdildi', 'KrediKarti', 0),
(19, 5, 1, 19, 115.00, 'TeslimEdildi', 'Nakit',      0),
(20, 1, 2, 20, 155.00, 'TeslimEdildi', 'KrediKarti', 0),
(1,  3, 3, 1,  300.00, 'TeslimEdildi', 'KrediKarti', 0),
(2,  4, 4, 2,  210.00, 'TeslimEdildi', 'Nakit',      0),
(3,  5, 5, 3,  225.00, 'TeslimEdildi', 'KrediKarti', 0),
(4,  1, 1, 4,  145.00, 'TeslimEdildi', 'Nakit',      0),
(5,  2, 2, 5,  190.00, 'TeslimEdildi', 'KrediKarti', 0),
(6,  3, 3, 6,  280.00, 'TeslimEdildi', 'KrediKarti', 0),
(7,  4, 4, 7,  160.00, 'TeslimEdildi', 'Nakit',      0),
(8,  5, 5, 8,  235.00, 'TeslimEdildi', 'KrediKarti', 0),
(9,  1, 1, 9,  120.00, 'TeslimEdildi', 'Nakit',      0),
(10, 2, 2, 10, 175.00, 'TeslimEdildi', 'KrediKarti', 0),
(11, 3, 3, 11, 290.00, 'TeslimEdildi', 'KrediKarti', 0),
(12, 4, 4, 12, 180.00, 'TeslimEdildi', 'Nakit',      0),
(13, 5, 5, 13, 240.00, 'TeslimEdildi', 'KrediKarti', 0),
(14, 1, 1, 14, 165.00, 'TeslimEdildi', 'Nakit',      0),
(15, 2, 2, 15, 200.00, 'TeslimEdildi', 'KrediKarti', 0),
(16, 3, 3, 16, 275.00, 'TeslimEdildi', 'KrediKarti', 0),
(17, 4, 4, 17, 195.00, 'TeslimEdildi', 'Nakit',      0),
(18, 5, 5, 18, 230.00, 'TeslimEdildi', 'KrediKarti', 0),
(19, 1, 1, 19, 140.00, 'TeslimEdildi', 'Nakit',      0),
(20, 2, 2, 20, 185.00, 'TeslimEdildi', 'KrediKarti', 0),
(1,  4, 3, 1,  215.00, 'TeslimEdildi', 'KrediKarti', 0),
(2,  5, 4, 2,  250.00, 'TeslimEdildi', 'Nakit',      0),
(3,  1, 5, 3,  135.00, 'TeslimEdildi', 'KrediKarti', 0),
(4,  2, 1, 4,  220.00, 'TeslimEdildi', 'Nakit',      0),
(5,  3, 2, 5,  295.00, 'TeslimEdildi', 'KrediKarti', 0),
(6,  4, 3, 6,  175.00, 'TeslimEdildi', 'KrediKarti', 0),
(7,  5, 4, 7,  245.00, 'TeslimEdildi', 'Nakit',      0),
(8,  1, 5, 8,  130.00, 'TeslimEdildi', 'KrediKarti', 0),
(9,  2, 1, 9,  210.00, 'TeslimEdildi', 'Nakit',      0),
(10, 3, 2, 10, 260.00, 'TeslimEdildi', 'KrediKarti', 0),
(11, 4, 3, 11, 195.00, 'TeslimEdildi', 'KrediKarti', 0),
(12, 5, 4, 12, 115.00, 'TeslimEdildi', 'Nakit',      0),
(13, 1, 5, 13, 155.00, 'TeslimEdildi', 'KrediKarti', 0),
(14, 2, 1, 14, 300.00, 'TeslimEdildi', 'Nakit',      0),
(15, 3, 2, 15, 210.00, 'TeslimEdildi', 'KrediKarti', 0),
(16, 4, 3, 16, 225.00, 'TeslimEdildi', 'KrediKarti', 0),
(17, 5, 4, 17, 145.00, 'TeslimEdildi', 'Nakit',      0),
(18, 1, 5, 18, 190.00, 'TeslimEdildi', 'KrediKarti', 0),
(19, 2, 1, 19, 280.00, 'TeslimEdildi', 'Nakit',      0),
(20, 3, 2, 20, 160.00, 'TeslimEdildi', 'KrediKarti', 0),
(1,  5, 3, 1,  235.00, 'TeslimEdildi', 'KrediKarti', 0),
(2,  1, 4, 2,  120.00, 'TeslimEdildi', 'Nakit',      0),
(3,  2, 5, 3,  175.00, 'TeslimEdildi', 'KrediKarti', 0),
(4,  3, 1, 4,  290.00, 'TeslimEdildi', 'Nakit',      0),
(5,  4, 2, 5,  180.00, 'TeslimEdildi', 'KrediKarti', 0),
(6,  5, 3, 6,  240.00, 'TeslimEdildi', 'KrediKarti', 0),
(7,  1, 4, 7,  165.00, 'TeslimEdildi', 'Nakit',      0),
(8,  2, 5, 8,  200.00, 'TeslimEdildi', 'KrediKarti', 0),
(9,  3, 1, 9,  275.00, 'TeslimEdildi', 'Nakit',      0),
(10, 4, 2, 10, 230.00, 'TeslimEdildi', 'KrediKarti', 0),
(11, 5, 3, 11, 185.00, 'TeslimEdildi', 'KrediKarti', 0),
(12, 1, 4, 12, 140.00, 'TeslimEdildi', 'Nakit',      0),
(13, 2, 5, 13, 210.00, 'TeslimEdildi', 'KrediKarti', 0),
(14, 3, 1, 14, 295.00, 'TeslimEdildi', 'Nakit',      0),
(15, 4, 2, 15, 175.00, 'TeslimEdildi', 'KrediKarti', 0),
(16, 5, 3, 16, 245.00, 'TeslimEdildi', 'KrediKarti', 0),
(17, 1, 4, 17, 130.00, 'TeslimEdildi', 'Nakit',      0),
(18, 2, 5, 18, 220.00, 'TeslimEdildi', 'KrediKarti', 0),
(19, 3, 1, 19, 260.00, 'TeslimEdildi', 'Nakit',      0),
(20, 4, 2, 20, 195.00, 'TeslimEdildi', 'KrediKarti', 0),
(19, 5, 3, 19,  85.00, 'TeslimEdildi', 'Havuz',      1),
(19, 1, 4, 19,  95.00, 'TeslimEdildi', 'Havuz',      1),
(20, 2, 5, 20,  90.00, 'TeslimEdildi', 'Havuz',      1),
(20, 3, 1, 20, 110.00, 'TeslimEdildi', 'Havuz',      1),
(20, 4, 2, 20, 100.00, 'TeslimEdildi', 'Havuz',      1),
(1,  1, 1, 1,  110.00, 'TeslimEdildi', 'KrediKarti', 0),
(2,  2, 2, 2,  125.00, 'TeslimEdildi', 'Nakit',      0),
(3,  3, 3, 3,  140.00, 'TeslimEdildi', 'KrediKarti', 0),
(4,  4, 4, 4,  130.00, 'TeslimEdildi', 'Nakit',      0),
(5,  5, 5, 5,  120.00, 'TeslimEdildi', 'KrediKarti', 0);
GO

INSERT INTO SiparisDetay (SiparisID, UrunID, Miktar, BirimFiyat)
SELECT s.SiparisID, v.UrunID, v.Miktar, v.BirimFiyat
FROM Siparis s
CROSS JOIN (VALUES
(1,  1, 120.00),(1,  6,  20.00),
(2,  11, 95.00),(2,  16, 55.00),
(3,  21,150.00),(3,  22,130.00),
(4,  31, 85.00),(4,  34,130.00),
(5,  41,115.00),(5,  42,125.00),
(6,  2, 100.00),(6,  8,  10.00),
(7,  12, 90.00),(7,  17, 35.00),
(8,  23,140.00),(8,  24,145.00),
(9,  32, 95.00),(9,  39, 20.00),
(10, 43,110.00),(10, 49, 25.00)
) v(RowNum, UrunID, BirimFiyat, Miktar)
WHERE s.SiparisID = (SELECT MIN(SiparisID) FROM Siparis) + v.RowNum - 1;
GO

INSERT INTO AskidaBagis (MusteriID, UrunID, Tutar, GizliMi, Aciklama) VALUES
(1,    NULL, 100.00, 0, 'Hayırlı olsun'),
(2,    NULL, 200.00, 1, NULL),
(3,    NULL, 150.00, 0, 'İyi günler dilerim'),
(4,    NULL,  50.00, 1, NULL),
(5,    NULL, 250.00, 0, 'Herkese hayırlı olsun'),
(6,    NULL, 100.00, 1, NULL),
(7,    NULL,  75.00, 0, NULL),
(8,    NULL, 300.00, 1, NULL),
(NULL, NULL, 500.00, 1, NULL),
(10,   NULL, 100.00, 0, 'Küçük bir katkı');
GO

INSERT INTO AskidaKullanim (MusteriID, SiparisID, Tutar)
SELECT 19, SiparisID,  85.00 FROM Siparis WHERE MusteriID=19 AND AskidanMi=1 AND ToplamTutar= 85.00
UNION ALL
SELECT 19, SiparisID,  95.00 FROM Siparis WHERE MusteriID=19 AND AskidanMi=1 AND ToplamTutar= 95.00
UNION ALL
SELECT 20, SiparisID,  90.00 FROM Siparis WHERE MusteriID=20 AND AskidanMi=1 AND ToplamTutar= 90.00
UNION ALL
SELECT 20, SiparisID, 110.00 FROM Siparis WHERE MusteriID=20 AND AskidanMi=1 AND ToplamTutar=110.00
UNION ALL
SELECT 20, SiparisID, 100.00 FROM Siparis WHERE MusteriID=20 AND AskidanMi=1 AND ToplamTutar=100.00;
GO

INSERT INTO IhtiyacDogrulama (MusteriID, DogrulayiciNot, DogrulanmaTarihi, Durum) VALUES
(19, 'Gelir belgesi incelendi, uygun bulundu.',     GETDATE(), 'Onaylandi'),
(20, 'Sosyal hizmet raporu mevcut, onaylandı.',     GETDATE(), 'Onaylandi'),
(1,  'Belgeler eksik, tekrar başvurması gerekiyor.', NULL,     'Reddedildi'),
(2,  NULL, NULL, 'Bekliyor'),
(3,  NULL, NULL, 'Bekliyor');
GO
