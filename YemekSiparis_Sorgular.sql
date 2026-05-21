USE YemekSiparisPlatformu;
GO

CREATE VIEW vw_AktifRestoranMenuleri AS
SELECT 
    r.RestoranID,
    r.RestoranAdi,
    r.RestoranPuani,
    k.KategoriAdi,
    u.UrunID,
    u.UrunAdi,
    u.Fiyat,
    u.Aciklama
FROM Restoran r
INNER JOIN Urun u     ON r.RestoranID = u.RestoranID
INNER JOIN Kategori k ON u.KategoriID = k.KategoriID
WHERE r.IsActive = 1 AND u.IsActive = 1;
GO

CREATE VIEW vw_AskidaYemekHavuzDurumu AS
SELECT
    h.ToplamBakiye,
    h.ToplamBagis,
    h.ToplamKullanim,
    h.GuncellenmeTarihi,
    (SELECT COUNT(*) FROM AskidaBagis)    AS ToplamBagisSayisi,
    (SELECT COUNT(*) FROM AskidaKullanim) AS ToplamKullanimSayisi,
    (SELECT COUNT(*) FROM Musteri 
     WHERE IhtiyacDogrulandiMi = 1)       AS OnayliIhtiyacSahibiSayisi
FROM AskidaHavuz h
WHERE h.HavuzID = 1;
GO

CREATE TRIGGER trg_CiroGuncelle
ON Siparis
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Durum)
    BEGIN
        UPDATE Restoran
        SET ToplamCiro = ToplamCiro + i.ToplamTutar
        FROM Restoran r
        INNER JOIN inserted i ON r.RestoranID = i.RestoranID
        INNER JOIN deleted d  ON d.SiparisID  = i.SiparisID
        WHERE i.Durum = 'TeslimEdildi'
          AND d.Durum != 'TeslimEdildi';
    END
END;
GO

CREATE TRIGGER trg_HavuzBakiyeDus
ON AskidaKullanim
AFTER INSERT
AS
BEGIN
    UPDATE AskidaHavuz
    SET ToplamBakiye   = ToplamBakiye   - i.Tutar,
        ToplamKullanim = ToplamKullanim + i.Tutar,
        GuncellenmeTarihi = GETDATE()
    FROM AskidaHavuz h
    INNER JOIN inserted i ON h.HavuzID = 1;
END;
GO

CREATE NONCLUSTERED INDEX IX_Siparis_MusteriID
    ON Siparis(MusteriID)
    INCLUDE (SiparisTarihi, ToplamTutar, Durum);
GO

CREATE NONCLUSTERED INDEX IX_Urun_RestoranID
    ON Urun(RestoranID)
    INCLUDE (UrunAdi, Fiyat, IsActive);
GO

CREATE NONCLUSTERED INDEX IX_AskidaBagis_Tarih
    ON AskidaBagis(BagisTarihi DESC);
GO

SELECT 
    s.SiparisID,
    m.Ad + ' ' + m.Soyad   AS MusteriAdi,
    r.RestoranAdi,
    k.Ad + ' ' + k.Soyad   AS KuryeAdi,
    u.UrunAdi,
    sd.Miktar,
    sd.BirimFiyat,
    sd.Miktar * sd.BirimFiyat AS SatirToplam,
    s.ToplamTutar,
    s.Durum,
    s.OdemeYontemi,
    s.SiparisTarihi
FROM Siparis s
INNER JOIN Musteri m       ON s.MusteriID  = m.MusteriID
INNER JOIN Restoran r      ON s.RestoranID = r.RestoranID
LEFT  JOIN Kurye k         ON s.KuryeID    = k.KuryeID
INNER JOIN SiparisDetay sd ON s.SiparisID  = sd.SiparisID
INNER JOIN Urun u          ON sd.UrunID    = u.UrunID
ORDER BY s.SiparisID;
GO

SELECT 
    r.RestoranAdi,
    COUNT(s.SiparisID)  AS ToplamSiparisSayisi,
    SUM(s.ToplamTutar)  AS ToplamCiro,
    AVG(s.ToplamTutar)  AS OrtalamaSepetTutari
FROM Restoran r
INNER JOIN Siparis s ON r.RestoranID = s.RestoranID
WHERE s.Durum = 'TeslimEdildi'
  AND s.SiparisTarihi >= DATEADD(MONTH, -1, GETDATE())
GROUP BY r.RestoranID, r.RestoranAdi
HAVING COUNT(s.SiparisID) > 5
ORDER BY ToplamCiro DESC;
GO

SELECT 
    m.MusteriID,
    m.Ad + ' ' + m.Soyad AS MusteriAdi,
    m.Email,
    COUNT(s.SiparisID)   AS ToplamSiparis
FROM Musteri m
INNER JOIN Siparis s ON m.MusteriID = s.MusteriID
WHERE m.IsActive = 1
  AND m.MusteriID NOT IN (
      SELECT DISTINCT MusteriID 
      FROM AskidaBagis 
      WHERE MusteriID IS NOT NULL
  )
GROUP BY m.MusteriID, m.Ad, m.Soyad, m.Email
HAVING COUNT(s.SiparisID) > 0
ORDER BY ToplamSiparis DESC;
GO