% =========================================================================
% Dikdörtgen Boru İçindeki Potansiyel Dağılımı ve Yüzde Hata Analizi
% =========================================================================
clear; clc; close all;

% --- 1. PARAMETRELER VE İZGARA (MESH) TANIMI ---
a = 1.0;  % Kutu genişliği (x ekseni)
b = 1.0;  % Kutu yüksekliği (y ekseni)
V0 = 1.0; % Üst duvar potansiyeli

% Kutueq 100x100 nokta ile ızgara oluşturulması
nx = 100;
ny = 100;
x = linspace(0, a, nx);
y = linspace(0, b, ny);
[X, Y] = meshgrid(x, y);

% --- 2. POTANSİYEL DAĞILIMI HESABI (N = 50 TERİM) ---
N_terms_plot = 50;
Phi = zeros(size(X));

for i = 1:N_terms_plot
    n = 2*i - 1; % Sadece tek sayılar (1, 3, 5, 7...)
    
    katsayi = (4 * V0) / (n * pi * sinh(n * pi * b / a));
    x_kismi = sin(n * pi * X / a);
    y_kismi = sinh(n * pi * Y / a);
    
    Phi = Phi + katsayi * x_kismi .* y_kismi;
end

% --- 3. POTANSİYEL DAĞILIMININ ÇİZİLMESİ ---
figure('Name', 'Potansiyel Dagilimi', 'Color', 'w');
contourf(X, Y, Phi, 50, 'LineColor', 'none');
colormap(jet);
colorbar;
title('Dikdörtgen Boru İçindeki Potansiyel Dağılımı \varphi(x,y)');
xlabel('x');
ylabel('y');
axis square;
set(gca, 'Color', 'w'); % Eksen arka planını garanti beyaz yapar
grid on;

% --- 4. YÜZDE HATA HESABI VE ÇİZİMİ ---
% Referans noktası (Kutunun tam ortası: x=0.5, y=0.5)
x_ref = 0.5;
y_ref = 0.5;


% 50 terim makine hassasiyeti için fazlasıyla yeterlidir. 
% Daha büyük sayılar (örn: 500) Inf/Inf = NaN hatasına (overflow) yol açar.
N_exact = 50; 
phi_exact = 0;
for i = 1:N_exact
    n = 2*i - 1;
    katsayi = (4 * V0) / (n * pi * sinh(n * pi * b / a));
    phi_exact = phi_exact + katsayi * sin(n * pi * x_ref / a) * sinh(n * pi * y_ref / a);
end

% Terim sayısına göre (N = 1'den 20'ye kadar) hata hesabı
max_N_test = 20;
percentage_errors = zeros(1, max_N_test);

for N = 1:max_N_test
    phi_N = 0;
    for i = 1:N
        n = 2*i - 1;
        katsayi = (4 * V0) / (n * pi * sinh(n * pi * b / a));
        phi_N = phi_N + katsayi * sin(n * pi * x_ref / a) * sinh(n * pi * y_ref / a);
    end
    percentage_errors(N) = abs((phi_exact - phi_N) / phi_exact) * 100;
end

% Yüzde Hata Grafiğinin Çizilmesi
figure('Name', 'Yuzde Hata', 'Color', 'w');
plot(1:max_N_test, percentage_errors, '-o', ...
    'LineWidth', 1.5, ...
    'MarkerSize', 6, ...
    'MarkerFaceColor', 'b', ...
    'Color', 'b');
title('Terim Sayısına Göre Yüzde Hata (Referans Noktası: x=0.5, y=0.5)');
xlabel('Hesaplamada Kullanılan Terim Sayısı (N)');
ylabel('Yüzde Hata (%)');
xticks(1:max_N_test);
set(gca, 'Color', 'w'); % Eksen arka planını garanti beyaz yapar
grid on;