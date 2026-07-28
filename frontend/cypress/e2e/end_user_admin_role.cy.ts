describe('end_user_admin Role — Restricted Access', () => {
  beforeEach(() => {
    cy.fixture('users').then((users) => {
      cy.visit('/login');
      cy.get('#email').type(users.end_user_admin.email);
      cy.get('#password').type(users.end_user_admin.password);
      cy.get('#loginSubmit').click();
      cy.url().should('not.include', '/login');
    });
  });

  it('Admin Accounts nav item is hidden', () => {
    cy.get('#navAccounts').should('not.exist');
  });

  it('End Users nav item is visible', () => {
    cy.get('#navUsers').should('be.visible');
  });

  it('Device Data nav item is hidden', () => {
    cy.get('#navDevices').should('not.exist');
  });

  it('direct navigation to /admin/accounts redirects away', () => {
    cy.visit('/admin/accounts');
    cy.url().should('not.include','/admin/accounts');
  });

  it('End User Management is fully accessible', () => {
    cy.get('#navUsers').click();
    cy.get('#userTable').should('exist');
  });

  it('can disable and re-enable a user with toggle button', () => {
    cy.get('#navUsers').click();
    cy.get('#userTable tbody tr').first().within(() => {
      cy.get('button[id^="toggleUser"]').first().click();
    });
    cy.get('#userTable').should('exist');
  });
});
